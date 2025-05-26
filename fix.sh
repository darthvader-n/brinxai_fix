#!/bin/bash

# Знаходимо шлях до тому, змонтованого в контейнері brinxai_relay_amd64
VOLUME_PATH=$(docker inspect brinxai_relay_amd64 --format '{{ range .Mounts }}{{ if eq .Destination "/etc/openvpn" }}{{ .Source }}{{ end }}{{ end }}')

if [ -z "$VOLUME_PATH" ]; then
  echo "Не вдалося знайти змонтований том /etc/openvpn у контейнері brinxai_relay_amd64"
  exit 1
fi

# Шукаємо файл ta.key в каталозі тому
TA_KEY_PATH=$(find "$VOLUME_PATH" -type f -name "ta.key" | head -n 1)

if [ -z "$TA_KEY_PATH" ]; then
  echo "Файл ta.key не знайдено в $VOLUME_PATH"
  exit 1
fi

# Копіюємо файл до openvpn_data
DEST_PATH="/var/lib/docker/volumes/openvpn_data/_data/"

cp "$TA_KEY_PATH" "$DEST_PATH"

if [ $? -eq 0 ]; then
  echo "Файл ta.key успішно скопійовано в $DEST_PATH"
else
  echo "Помилка копіювання файлу"
fi


CONF_FILE="/var/lib/docker/volumes/openvpn_data/_data/openvpn.conf"

sed -i 's/^push "push "redirect-gateway def1 bypass-dhcp""/push "redirect-gateway def1 bypass-dhcp"/' "$CONF_FILE"

# Перезапуск контейнера
docker restart brinxai_relay_amd64
