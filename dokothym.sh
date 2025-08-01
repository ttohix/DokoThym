#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

function banner() {
  echo -e "${GREEN}"
  echo "╔═══════════════════════════════╗"
  echo "║         DokoThym Script       ║"
  echo "║       By @amirhtym (Telegram) ║"
  echo "╚═══════════════════════════════╝"
  echo -e "${NC}"
}

function install_xray() {
  echo "[*] نصب Xray..."
  sudo bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
}

function create_config() {
  read -p "چند پورت برای تونل نیاز دارید؟ " PORT_COUNT
  PORTS=()
  for ((i=1; i<=PORT_COUNT; i++)); do
    read -p "پورت شماره $i: " port
    PORTS+=($port)
  done

  read -p "IP مقصد را وارد کنید: " DEST_IP

  CONFIG_PATH="/usr/local/etc/xray/config.json"
  echo "[*] ساخت config.json در $CONFIG_PATH"

  cat > $CONFIG_PATH <<EOF
{
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
EOF

  for ((i=0; i<${#PORTS[@]}; i++)); do
    port=${PORTS[$i]}
    comma=","
    if [[ $i == $((${#PORTS[@]} - 1)) ]]; then
      comma=""
    fi

    cat >> $CONFIG_PATH <<EOF
    {
      "listen": null,
      "port": $port,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "$DEST_IP",
        "followRedirect": false,
        "network": "tcp,udp",
        "port": $port
      },
      "tag": "inbound-$port"
    }$comma
EOF
  done

  cat >> $CONFIG_PATH <<EOF
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    }
  ]
}
EOF

  echo "[*] ریستارت Xray..."
  sudo systemctl restart xray
  echo -e "[✓] تنظیمات انجام شد و Xray ریستارت شد.\n"
}

function menu() {
  banner
  echo "اسکریپت تونل ساز: DokoThym"
  echo "1) نصب Xray"
  echo "2) ساخت تونل و پیکربندی"
  echo "3) خروج"
  echo ""

  read -p "یک گزینه انتخاب کنید: " CHOICE
  case $CHOICE in
    1) install_xray ;;
    2) create_config ;;
    3) exit 0 ;;
    *) echo "گزینه نامعتبر." ;;
  esac
}

while true; do
  menu
done
