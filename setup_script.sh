#!/bin/bash

# Function to check if cowsay is installed and install it if not
check_and_install_cowsay() {
  if ! command -v cowsay &> /dev/null; then
    echo "cowsay is not installed. Installing cowsay..."
    sudo apt-get install cowsay -y
  fi
}

# Function to display a welcome message with a cow
welcome_message() {
  check_and_install_cowsay
  cowsay -f ghostbusters "Welcome to the SIEM, HIDS, and NIDS Setup Script"
  echo "This script will help you set up a security monitoring environment."
  echo "It includes the following components:"
  echo "1. SIEM (Elasticsearch, Kibana, Filebeat)"
  echo "2. NIDS (Suricata)"
  echo "3. HIDS (Wazuh Manager)"
  echo "The SIEM will be installed with Elasticsearch version 7.17.13 and Wazuh version 4.5, as they were compatible during the script creation."
}

# Function to install SIEM and display a message with a cow
install_siem() {
  check_and_install_cowsay
  cowsay -f ghost "Starting SIEM setup..."
  chmod +x siem_setup.sh
  ./siem_setup.sh
  cowsay -f tux "SIEM setup completed. Press Enter to continue..."
  read -p ""
}

# Function to install Suricata (NIDS) and display a message with a cow
install_suricata() {
  check_and_install_cowsay
  cowsay -f ghost "Starting Suricata setup..."
  chmod +x suricata_setup.sh
  ./suricata_setup.sh
  cowsay -f tux "Suricata setup completed. Press Enter to continue..."
  read -p ""
}

# Function to install Wazuh (HIDS) and display a message with a cow
install_wazuh() {
  check_and_install_cowsay
  cowsay -f ghost "Starting Wazuh setup..."
  chmod +x wazuh_setup.sh
  ./wazuh_setup.sh
  cowsay -f tux "Wazuh setup completed. Press Enter to continue..."
  read -p ""
}

# Function to check system requirements
check_system_requirements() {
  check_and_install_cowsay
  total_ram=$(free -m | awk '/^Mem:/{print $2}')
  available_disk_space=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')

  cowsay -f ghost "Checking system requirements..."
  echo "Total RAM: ${total_ram} MB"
  echo "Available Disk Space: ${available_disk_space} GB"

  if [ "$total_ram" -lt 4096 ] || [ "$available_disk_space" -lt 20 ]; then
    cowsay -f ghostbusters "WARNING: Your system does not meet the minimum requirements."
    read -p "Do you want to continue with the installation? (y/n): " continue_choice
    if [ "$continue_choice" != "y" ]; then
      cowsay -f elephant "Setup aborted."
      exit 1
    fi
  else
    cowsay -f tux "System requirements met. Continuing with the installation."
  fi
}

# Color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Welcome message and description
echo -e "${GREEN}Welcome to the SIEM, HIDS, and NIDS Setup Script${NC}"

# Ask for user confirmation to continue
read -p "Do you want to proceed with the setup? (y/n): " choice

if [ "$choice" != "y" ]; then
  cowsay -f elephant "Setup aborted."
  exit 1
fi

# Check system requirements
check_system_requirements

# Ask the user which components to install
read -p "Do you want to install the SIEM (Elasticsearch, Kibana, Filebeat)? (y/n): " install_siem_choice
if [ "$install_siem_choice" == "y" ]; then
  install_siem
fi

read -p "Do you want to install Suricata (NIDS)? (y/n): " install_suricata_choice
if [ "$install_suricata_choice" == "y" ]; then
  install_suricata
fi

read -p "Do you want to install Wazuh (HIDS)? (y/n): " install_wazuh_choice
if [ "$install_wazuh_choice" == "y" ]; then
  install_wazuh
fi

cowsay -f tux "Setup completed successfully."
