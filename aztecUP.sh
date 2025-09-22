#!/bin/bash

sed -i '1s|^ETHEREUM_HOSTS=.*|ETHEREUM_HOSTS=https://ethereum-sepolia-rpc.publicnode.com|' aztec-sequencer/.env

docker stop aztec-sequencer && docker rm aztec-sequencer

docker pull aztecprotocol/aztec:latest

    docker run -d \
      --name aztec-sequencer \
      --network host \
      --entrypoint /bin/sh \
      --env-file "$HOME/aztec-sequencer/.env" \
      -e DATA_DIRECTORY=/data \
      -e LOG_LEVEL=debug \
      -v "$HOME/aztec-sequencer/data":/data \
      aztecprotocol/aztec:latest \
      -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'
