#!/bin/bash

echo -e "[Unit]\nDescription=Monitoring Script\nAfter=network.target\n\n[Service]\nExecStart=/bin/bash /root/Monitoring.sh\nRestart=always\nUser=root\nWorkingDirectory=/root\nStandardOutput=append:/var/log/monitoring.log\nStandardError=append:/var/log/monitoring.log\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/monitoring.service > /dev/null

docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --cleanup \
  --interval 3600
