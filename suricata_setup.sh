#!/bin/bash

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
echo "Installing dependencies..."
apt-get update
apt-get install -y libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev \
                libnet1-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev \
                libcap-ng-dev libcap-ng0 make libmagic-dev \
                libnss3-dev libgeoip-dev liblua5.1-0-dev libhiredis-dev libevent-dev \
                python3-yaml rustc cargo

if [ $? -ne 0 ]; then
    echo "Error: Dependency installation failed."
    exit 1
fi

# Step 2: Install Suricata
echo "Installing Suricata..."
add-apt-repository ppa:oisf/suricata-stable
apt-get update
apt-get install -y suricata

if [ $? -ne 0 ]; then
    echo "Error: Suricata installation failed."
    exit 1
fi

# Step 3: Find the active interface
echo "Finding active interface..."

interface=$(ip route show default | grep -oP 'dev \K\S+' | awk '{print $1}')
if [ -z "$interface" ]; then
    echo "Error: Unable to determine the active interface."
    exit 1
fi


echo "Configuration file updated with the active interface: $interface"


# Update the /etc/default/suricata file with the correct IFACE
echo "Updating /etc/default/suricata with IFACE=$interface..."
sed -i "s/^IFACE=.*/IFACE=$interface/" /etc/default/suricata
sed -i "s/\$interface/$interface/g" /home/analyst/Desktop/suricata_temp.yaml


# Step 4: Update Suricata configuration files with the active interface
echo "Updating Suricata configuration files..."


# Step 5: Start Suricata
echo "Starting Suricata..."
systemctl start suricata

sleep 10

# Step 6: Update suricata config file
cp suricata_temp.yaml /etc/suricata/suricata.yaml

systemctl restart suricata

# Wait for Suricata to start
echo "Waiting for Suricata to start..."
while true; do
    if grep -q "Engine started" /var/log/suricata/suricata.log; then
        break
    fi
    sleep 10
done

if [ $? -ne 0 ]; then
    echo "Error: Suricata failed to start."
else
    echo "Suricata is now running."
fi

# Step 7: Install and configure suricata-update

echo "Installing and configuring suricata-update..."

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

echo "Restarting Suricata..."

systemctl restart suricata



# Check for Suricata restart

echo "Checking for Suricata restart..."

while true; do

    if grep -q "Engine started" /var/log/suricata/suricata.log; then

        break

    fi

    sleep 10

done



echo "Suricata has been restarted with updated rules."


# Step 8: Enable and configure Filebeat Suricata module
echo "Enabling and configuring Filebeat Suricata module..."
sudo filebeat modules enable suricata

# Modify the Suricata module settings
echo "Modifying Suricata module settings..."
cat <<EOL > /etc/filebeat/modules.d/suricata.yml
- module: suricata
  eve:
    enabled: true
    var.paths: ["/var/log/suricata/eve.json"]
EOL

# Restart Filebeat
echo "Restarting Filebeat..."
systemctl restart filebeat

# Execute Filebeat setup
echo "Running Filebeat setup..."
filebeat setup -e

echo "Filebeat is now configured and running."

exit 0
