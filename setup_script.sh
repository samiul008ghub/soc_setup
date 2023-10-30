#!/bin/bash

# Function to check if lolcat is installed and install it if not
check_and_install_lolcat() {
  if ! command -v lolcat &> /dev/null; then
    echo "lolcat is not installed. Installing lolcat..."
    sudo apt-get install lolcat -y
  fi
}

# Function to check if figlet is installed and install it if not
check_and_install_figlet() {
  if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing figlet..."
    
    if command -v sudo &> /dev/null; then
      # Check the package manager and install figlet
      if command -v apt-get &> /dev/null; then
        sudo apt-get install figlet -y
      elif command -v yum &> /dev/null; then
        sudo yum install figlet -y
      # Add more package manager checks for other distributions if needed
      else
        echo "Unsupported package manager. Please install figlet manually."
      fi
    else
      echo "sudo is not available. Please install figlet manually."
    fi
  fi
}
# Function to display a welcome message with figlet and lolcat
welcome_message() {
  check_and_install_lolcat
  check_and_install_figlet
  figlet "SIEM & HIDS Setup" | lolcat
  echo "This script will help you set up a security monitoring environment."
  echo "It includes the following components:"
  echo "1. SIEM (Elasticsearch, Kibana, Filebeat)"
  echo "2. NIDS (Suricata)"
  echo "3. HIDS (Wazuh Manager)"
  echo "The SIEM will be installed with Elasticsearch version 7.17.13 and Wazuh version 4.5, as they were compatible during the script creation." | lolcat
}


# Function to install SIEM and display a message with figlet and lolcat
install_siem() {
  check_and_install_lolcat
  figlet "Starting SIEM Setup" | lolcat
  chmod +x siem_setup.sh
  ./siem_setup.sh
  figlet "SIEM Setup Completed" | lolcat
  read -p "Press Enter to continue..."
}

# Function to install Suricata (NIDS) and display a message with figlet and lolcat
install_suricata() {
  check_and_install_lolcat
  figlet "Starting Suricata Setup" | lolcat
  chmod +x suricata_setup.sh
  ./suricata_setup.sh
  figlet "Suricata Setup Completed" | lolcat
  read -p "Press Enter to continue..."
}

# Function to install Wazuh (HIDS) and display a message with figlet and lolcat
install_wazuh() {
  check_and_install_lolcat
  figlet "Starting Wazuh Setup" | lolcat
  chmod +x wazuh_setup.sh
  ./wazuh_setup.sh
  figlet "Wazuh Setup Completed" | lolcat
  read -p "Press Enter to continue..."
}

# Function to check system requirements
check_system_requirements() {
  check_and_install_lolcat
  total_ram=$(free -m | awk '/^Mem:/{print $2}')
  available_disk_space=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')

  echo "Checking Requirements" | lolcat
  echo "Total RAM: ${total_ram} MB" | lolcat
  echo "Available Disk Space: ${available_disk_space} GB" | lolcat

  if [ "$total_ram" -lt 4096 ] || [ "$available_disk_space" -lt 20 ]; then
    echo "Warning: Not Enough Resources." | lolcat
    read -p "Do you want to continue with the installation? (y/n): " continue_choice
    if [ "$continue_choice" != "y" ]; then
      figlet "Setup Aborted" | lolcat
      exit 1
    fi
  else
    figlet "Requirements Met" | lolcat
    echo "System requirements met. Continuing with the installation."
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
  figlet "Setup Aborted" | lolcat
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

figlet "All done!" | lolcat
