#!/bin/bash

# Color codes for formatting
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to install SIEM
install_siem() {
    echo -e "${GREEN}Starting SIEM setup...${NC}"
    chmod +x siem_setup_script.sh
    ./siem_setup_script.sh
}

# Function to install Suricata (NIDS)
install_suricata() {
    echo -e "${GREEN}Starting Suricata setup...${NC}"
    chmod +x suricata_setup.sh
    ./suricata_setup.sh
}

# Function to install Wazuh (HIDS)
install_wazuh() {
    echo -e "${GREEN}Starting Wazuh setup...${NC}"
    chmod +x wazuh_setup.sh
    ./wazuh_setup.sh
}

# Welcome message and description
echo -e "${GREEN}Welcome to the SIEM, HIDS, and NIDS Setup Script${NC}"
echo "This script will help you set up a security monitoring environment."
echo "It includes the following components:"
echo "1. SIEM (Elasticsearch, Kibana, Filebeat)"
echo "2. HIDS (Wazuh Manager)"
echo "3. NIDS (Suricata)"
echo "The SIEM will be installed with Elasticsearch version 7.17.13 and Wazuh version 4.5, as they were compatible during the script creation."

# Ask for user confirmation to continue
read -p "Do you want to proceed with the setup? (y/n): " choice

if [ "$choice" != "y" ]; then
    echo "Setup aborted."
    exit 1
fi

# Ask the user which components to install
read -p "Do you want to install the SIEM (Elasticsearch, Kibana, Filebeat)? (y/n): " install_siem_choice
read -p "Do you want to install Suricata (NIDS)? (y/n): " install_suricata_choice
read -p "Do you want to install Wazuh (HIDS)? (y/n): " install_wazuh_choice

# Execute the selected components
if [ "$install_siem_choice" == "y" ]; then
    install_siem
fi

if [ "$install_suricata_choice" == "y" ]; then
    install_suricata
fi

if [ "$install_wazuh_choice" == "y" ]; then
    install_wazuh
fi

echo -e "${GREEN}Setup completed successfully.${NC}"
