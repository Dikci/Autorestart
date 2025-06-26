#!/bin/bash

sudo kill -9 $(sudo lsof -t -i:8080)
docker stop aztec-sequencer
docker rm aztec-sequencer
docker stop watchtower
docker rm watchtower
docker stop gaianet_chat
docker rm gaianet_chat

docker run -d \
  --name aztec-sequencer \
  -p 8082:8080 \
  -p 40400:40400 \
  --entrypoint /bin/sh \
  --env-file "$HOME/aztec-sequencer/.env" \
  -e DATA_DIRECTORY=/data \
  -e LOG_LEVEL=debug \
  -v "$HOME/aztec-sequencer/data":/data \
  aztecprotocol/aztec:0.87.9 \
  -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'

docker run -d \
  --name watchtower \
  -p 8083:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --cleanup

  

  gaianet start
