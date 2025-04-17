#!/bin/bash

cd nwaku-compose
docker compose down -v
cd
rm -rf nwaku-compose
git clone https://github.com/waku-org/nwaku-compose
cd nwaku-compose
rm -rf keystore
rm -rf docker-compose.yml
wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/docker-compose.yml
cp /root/.env /root/nwaku-compose/
chmod +x register_rln.sh
./register_rln.sh
docker compose up -d
