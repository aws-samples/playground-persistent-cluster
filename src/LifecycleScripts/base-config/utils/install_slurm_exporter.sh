#!/bin/bash

set -x

# Check if Slurm ctld service is running to identify controller node:
if systemctl is-active --quiet slurmctld; then
    # Check if Go is installed, if not, install it
    if ! command -v go &> /dev/null; then
        echo "Go is not installed. Installing Go..."
        apt install -y golang
    else
        echo "Go is already installed."
    fi
    echo "This was identified as the controller node because Slurmctld is running. Begining SLURM Exporter Installation"
    # Dev branch to enable gpu accounting
    git clone -b development https://github.com/vpenso/prometheus-slurm-exporter.git
    cd prometheus-slurm-exporter
    make && cp bin/prometheus-slurm-exporter /usr/bin/
    tee /etc/systemd/system/prometheus-slurm-exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus SLURM Exporter

[Service]
Environment=PATH=/opt/slurm/bin:\$PATH
ExecStart=/usr/bin/prometheus-slurm-exporter -gpus-acct
Restart=on-failure
RestartSec=15
Type=simple

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now prometheus-slurm-exporter
    systemctl status prometheus-slurm-exporter
    echo "Prometheus SLURM Exporter installation completed successfully."
else
    echo "This was identified as a worker node because Slurmctld is not running. Did not begin Prometheus SLURM Exporter installation. Exiting gracefully."
    exit 0
fi
