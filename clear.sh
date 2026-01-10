#!/bin/bash

docker stop fizz-node
docker rm fizz-node
docker volume ls
docker volume prune -f          # автоответ "y"
docker volume rm node-storage
docker system prune -a -f       # автоответ "y"
rm -rf multipleNEW.sh.1 multipleforlinux multiple.sh Ocean.sh.2 Ocean.sh.3 Ocean.sh.4 Ocean.sh.5 pop privasea .spheron


rm -rf Monitoring.sh
rm -rf .aztec .cysic aztec aztec-sequencer aztec.sh aztecUP.sh backupG backup_rl_swarm backuppp bless cysicM.sh cysic-verifier gen gensyn.sh nexusU.sh nexusU.sh.1 nexusU.sh.2 rl-swarm rpc.py rpc.sh swarm.pem tg_role.sh titan.sh.1
docker stop aztec-sequencer && docker rm aztec-sequencer
rm datagram-cli-x86_64-linux
rm -rf .datagram datagram-cli-x86_64-linux datagram-cli-x86_64-linux.1
tmux kill-session -t aztec
tmux kill-session -t update
tmux kill-session -t discord
tmux kill-session -t datagram
tmux kill-session -t hyperspace
tmux kill-session -t gensyn
tmux kill-session -t drosera
pm2 delete gensyn
sudo bash -c '
echo "[KILL SCREENS]"
screen -ls | grep -E "aztec|gensyn|datagram|cysic|bless" | awk "{print \$1}" | xargs -r screen -S {} -X quit

echo "[KILL PROCESSES]"
pkill -9 -f datagram
pkill -9 -f aztec
pkill -9 -f gensyn
pkill -9 -f cysic
pkill -9 -f bless
pkill -9 -f beam.smp
pkill -9 -f elixir
pkill -9 -f burrito
pkill -9 -f conference

echo "[REMOVE AUTOSTART]"
rm -f /etc/profile.d/*datagram*
rm -f /etc/profile.d/*aztec*
rm -f /etc/cron.*/*datagram*
rm -f /etc/cron.*/*aztec*
crontab -l 2>/dev/null | grep -Ev "datagram|aztec|gensyn|cysic|bless" | crontab -

echo "[REMOVE FILES]"
rm -rf /root/.datagram
rm -rf /root/datagram*
rm -rf /root/aztec*
rm -rf /root/.aztec
rm -rf /root/gensyn*
rm -rf /root/.gensyn
rm -rf /root/cysic*
rm -rf /root/.cysic
rm -rf /root/bless*
rm -rf /root/.bless

echo "[FINAL WIPE]"
find / -type f \( -iname "*datagram*" -o -iname "*aztec*" -o -iname "*gensyn*" -o -iname "*cysic*" -o -iname "*bless*" \) -exec rm -f {} \; 2>/dev/null
find / -type d \( -iname "*datagram*" -o -iname "*aztec*" -o -iname "*gensyn*" -o -iname "*cysic*" -o -iname "*bless*" \) -exec rm -rf {} \; 2>/dev/null

echo "✅ DONE — NOTHING WILL RESTART"
'

rm -rf .drosera .drosera.db auto_irys auto_irys_test.sh drosera-backup drosera drosera-operator drosera-operator-v1.23.0-x86_64-unknown-linux-gnu.tar.gz drosera.sh.1 drosera.sh drosera_half.sh droseranew.sh

docker stop unichain-node-op-node-1 unichain-node-execution-client-1
docker rm unichain-node-op-node-1 unichain-node-execution-client-1
sudo rm -r unichain-node

sudo bash -c '
SERVICES="auto_irys datagram gensyn irys-auto drosera"

echo "[STOP & DISABLE]"
for s in $SERVICES; do
  systemctl stop $s.service 2>/dev/null
  systemctl disable $s.service 2>/dev/null
done

echo "[REMOVE UNIT FILES]"
rm -f /etc/systemd/system/auto_irys.service
rm -f /etc/systemd/system/datagram.service
rm -f /etc/systemd/system/gensyn.service
rm -f /etc/systemd/system/irys-auto.service
rm -f /lib/systemd/system/auto_irys.service
rm -f /lib/systemd/system/datagram.service
rm -f /lib/systemd/system/gensyn.service
rm -f /lib/systemd/system/irys-auto.service
rm -f /lib/systemd/system/drosera.service

echo "[RELOAD SYSTEMD]"
systemctl daemon-reexec
systemctl daemon-reload

echo "✅ SERVICES REMOVED"
'


