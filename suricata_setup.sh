#!/bin/bash

# Color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for previous Suricata installation
if dpkg -l | grep -q suricata; then
    read -p "A previous Suricata installation is detected. Do you want to remove it and continue (y/n)? " remove_previous

    if [ "$remove_previous" == "y" ]; then
        echo "Removing the previous Suricata installation..."
        apt-get remove --purge -y suricata
    else
        echo "Aborted. Please remove the previous Suricata installation manually and run the script again."
        exit 1
    fi
fi

# Step 1: Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
apt-get update
apt-get install -y libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev \
                libnet1-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev \
                libcap-ng-dev libcap-ng0 make libmagic-dev \
                libnss3-dev libgeoip-dev liblua5.1-0-dev libhiredis-dev libevent-dev \
                python3-yaml rustc cargo

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Dependency installation failed.${NC}"
    exit 1
fi

# Step 2: Install Suricata
echo -e "${GREEN}Installing Suricata...${NC}"
add-apt-repository ppa:oisf/suricata-stable
apt-get update
apt-get install -y suricata

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Suricata installation failed.${NC}"
    exit 1
fi

# Step 3: Find the active interface
echo -e "${GREEN}Finding active interface...${NC}"

interface=$(ip route show default | grep -oP 'dev \K\S+' | awk '{print $1}')
if [ -z "$interface" ]; then
    echo -e "${RED}Error: Unable to determine the active interface.${NC}"
    exit 1
fi

echo "Configuration file updated with the active interface: $interface"

# Update the /etc/default/suricata file with the correct IFACE
echo -e "${GREEN}Updating /etc/default/suricata with IFACE=$interface...${NC}"
sed -i "s/^IFACE=.*/IFACE=$interface/" /etc/default/suricata

# Step 4: Update Suricata configuration files
echo -e "${GREEN}Updating Suricata configuration files...${NC}"

# Step 5: Start Suricata
echo -e "${GREEN}Starting Suricata...${NC}"
systemctl start suricata

sleep 10

# Step 6: Update suricata config file
sed -i "s/interface: enp0s3/interface: $(ip route show default | grep -oP 'dev \K\S+' | awk '{print $1}')/g" suricata_temp.yaml

cp suricata_temp.yaml /etc/suricata/suricata.yaml

systemctl restart suricata

# Wait for Suricata to start
echo -e "${GREEN}Waiting for Suricata to start...${NC}"
while true; do
    if grep -q "Engine started" /var/log/suricata/suricata.log; then
        break
    fi
    sleep 10
done

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Suricata failed to start.${NC}"
else
    echo -e "${GREEN}Suricata is now running.${NC}"
fi

# Step 7: Install and configure suricata-update
echo -e "${GREEN}Installing and configuring suricata-update...${NC}"

apt-get install -y python3-pip

pip3 install pyyaml

pip3 install https://github.com/OISF/suricata-update/archive/master.zip

# To upgrade suricata-update
pip3 install --pre --upgrade suricata-update
suricata-update
suricata-update update-sources

# To update enabled sources
suricata-update enable-source oisf/trafficid
suricata-update enable-source etnetera/aggressive
suricata-update enable-source sslbl/ssl-fp-blacklist
suricata-update enable-source et/open
suricata-update enable-source tgreen/hunting
suricata-update enable-source sslbl/ja3-fingerprints
suricata-update enable-source ptresearch/attackdetection

# Restart Suricata
echo -e "${GREEN}Restarting Suricata...${NC}"
systemctl restart suricata

# Check for Suricata restart
echo -e "${GREEN}Checking for Suricata restart...${NC}"
while true; do
    if grep -q "Engine started" /var/log/suricata/suricata.log; then
        break
    fi
    sleep 10
done

echo -e "${GREEN}Suricata has been restarted with updated rules.${NC}"

# Step 8: Enable and configure Filebeat Suricata module
echo -e "${GREEN}Enabling and configuring Filebeat Suricata module...${NC}"
sudo filebeat modules enable suricata

# Modify the Suricata module settings
echo -e "${GREEN}Modifying Suricata module settings...${NC}"
cat <<EOL > /etc/filebeat/modules.d/suricata.yml
- module: suricata
  eve:
    enabled: true
    var.paths: ["/var/log/suricata/eve.json"]
EOL

# Restart Filebeat
echo -e "${GREEN}Restarting Filebeat...${NC}"
systemctl restart filebeat

# Execute Filebeat setup
echo -e "${GREEN}Running Filebeat setup...${NC}"
filebeat setup -e

echo -e "${GREEN}Filebeat is now configured and running.${NC}"

exit 0
