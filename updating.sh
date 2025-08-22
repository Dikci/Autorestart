#!/bin/bash


tmux kill-session -t nexus
docker stop nexus && docker rm nexus && docker pull nexusxyz/nexus-cli:latest
tmux new-session -d -s nexus bash -c 'bash -c "set -a; . /etc/environment; set +a; docker stop nexus; docker rm nexus; docker run -it --init --name nexus nexusxyz/nexus-cli:latest start --node-id \$ID; exec bash"

npm install pm2 -g
pm2 delete gensyn
pm2 start /root/rl-swarm/run_rl_swarm.sh \
  --name gensyn \
  --interpreter bash \
  --cwd /root/rl-swarm
pm2 save
pm2 logs gensyn
