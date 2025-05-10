#!/bin/bash

docker stop hyperlane maycrypto_browser_Dikci
docker rm hyperlane maycrypto_browser_Dikci
rm -rf abstract-node hyperlane_db_base .nesa .nubit-validator .nubit-light-nubit-alphatestnet-1
rm -rf vps-browser-credentials.json
rm -r abstract-node hyperlane_db_base .nesa .nubit-validator .nubit-light-nubit-alphatestnet-1
docker system prune -a -f
rm -rf clear.sh
