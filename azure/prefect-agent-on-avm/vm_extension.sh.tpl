#!/bin/bash

#Set noninteractive for the front-end
export DEBIAN_FRONTEND=noninteractive
#Package updates and installation
sleep 5

echo "Running apt-get update"
sudo apt-get update -y && sudo apt-get install -y python3-pip &> /tmp/apt_get_update.out

#Install prefect
echo "Running pip install prefect"
sudo python3 -m pip install "prefect>=2.0b" &> /tmp/install_prefect.out

#Create a default work-queue
echo "Creating a default work-queue"
runuser -l ${adminuser} -c '/usr/local/bin/prefect work-queue create ${defaultqueue}'

echo "Creating the service config in /etc/systemd/system/prefect-agent.service"
cat << EOF > /etc/systemd/system/prefect-agent.service
[Unit]
Description=Prefect Agent Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=${adminuser}
ExecStart=/usr/local/bin/prefect agent start ${defaultqueue}

[Install]
WantedBy=default.target
EOF

#Reload systemctl to pickup the service
echo "Reloading systemctl"
systemctl daemon-reload

#Enable the service to start on boot
echo "Enabling the prefect-agent"
systemctl enable prefect-agent

#Start the service
echo "Starting the prefect agent"
systemctl start prefect-agent

#Wait for the service to start
sleep 2

#Configure the API Key 
echo "Setting the Cloud API Key" >> install_prefect.out
/usr/local/bin/prefect config set PREFECT_API_KEY=${api_key} >> install_prefect.out

#Configure the Prefect Cloud URL
echo "Setting the Cloud API Key" >> install_prefect.out
/usr/local/bin/prefect config set PREFECT_API_URL=${prefect_url} >> install_prefect.out