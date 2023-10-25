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



# Create a modified suricata_temp.yml configuration file



# Step 4: Update Suricata configuration files with the active interface
echo "Updating Suricata configuration files..."


# Step 5: Start Suricata
echo "Starting Suricata..."
systemctl start suricata

sleep 10

#cp suricata_temp.yml /etc/suricata/suricata.yaml


cp /home/analyst/Desktop/suricata_temp.yaml /etc/suricata/suricata.yaml
systemctl restart suricata

tail -f /var/log/suricata/suricata.log

if [ $? -ne 0 ]; then
    echo "Error: Suricata failed to start."
else
    echo "Suricata is now running."
fi

exit 0

