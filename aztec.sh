#!/bin/bash

docker stop aztec-sequencer && docker rm aztec-sequencer
rm datagram-cli-x86_64-linux
rm -rf .datagram datagram-cli-x86_64-linux datagram-cli-x86_64-linux.1
tmux kill-session -t aztec
tmux kill-session -t update
tmux kill-session -t discord
tmux kill-session -t datagram
tmux kill-session -t hyperspace
tmux kill-session -t clear
tmux kill-session -t gensyn
tmux kill-session -t drosera
exit
