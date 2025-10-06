#!/bin/bash

sudo npm i -g @irys/cli
wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/auto_irys_test.sh
chmod +x auto_irys_test.sh
sudo tee /etc/systemd/system/irys-auto.service > /dev/null << EOF
[Unit]
Description=Irys Auto Transaction Script
After=network-online.target

[Service]
ExecStart=/root/auto_irys_test.sh
Restart=always
RestartSec=86400
EnvironmentFile=/etc/environment

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable irys-auto
sudo systemctl start irys-auto
exit
