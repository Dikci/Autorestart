#!/bin/bash

sed -i 's|http://localhost:3000|http://localhost:3999|g' $(grep -rl "http://localhost:3000" ~/rl-swarm)
pm2 delete gensyn
pm2 start /root/rl-swarm/run_rl_swarm.sh \
  --name gensyn \
  --interpreter bash \
  --cwd /root/rl-swarm
pm2 save
pm2 logs gensyn
