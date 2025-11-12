#!/bin/bash

tmux kill-session -t clear
tmux kill-session -t aztec
tmux kill-session -t cysic
tmux kill-session -t dria
tmux kill-session -t drosera
tmux kill-session -t irys
curl -fsSL https://dria.co/launcher | bash
curl -fsSL https://ollama.com/install.sh | sh
dkn-compute-launcher start

sudo tee /etc/systemd/system/dria.service > /dev/null <<'EOF'
[Unit]
Description=Dria Compute Launcher Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/bin/bash -c 'source ~/.bashrc && /root/.dria/bin/dkn-compute-launcher start'
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable dria.service
sudo systemctl restart dria.service
journalctl -u dria -f -o cat
