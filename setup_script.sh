#!/bin/bash

# Color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check for root privileges
check_root_privileges() {
  if [[ $(id -u) -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run with root privileges.${NC}"
    exit 1
  fi
}

# Function to check if prerequisites are installed
check_prerequisites() {
  local prerequisites=("git" "curl" "figlet" "lolcat")
  local missing_prerequisites=()

  for prerequisite in "${prerequisites[@]}"; do
    if ! command_exists "$prerequisite"; then
      missing_prerequisites+=("$prerequisite")
    fi
  done

  if [ ${#missing_prerequisites[@]} -eq 0 ]; then
    echo -e "${GREEN}All prerequisites are installed.${NC}"
  else
    echo -e "${RED}Prerequisites missing:${NC}"
    for prerequisite in "${missing_prerequisites[@]}"; do
      echo -e "  - $prerequisite"
    done
    echo -e "Installing missing prerequisites..."
    install_prerequisites
  fi
}

# Function to install prerequisites if missing
install_prerequisites() {
  local prerequisites=("lsb-release" "curl" "apt-transport-https" "zip" "unzip" "gnupg" "lolcat" "figlet")

  echo -e "${GREEN}Installing prerequisites...${NC}"
  apt-get update
  apt-get install -y "${prerequisites[@]}"
  echo -e "${GREEN}All prerequisites have been installed.${NC}"
}

# Function to check if lolcat is installed and install it if not
check_and_install_lolcat() {
  if ! command_exists "lolcat"; then
    echo -e "${RED}lolcat is not installed. Installing lolcat...${NC}"
    if command_exists "sudo"; then
      sudo gem install lolcat
      echo -e "${GREEN}lolcat has been installed.${NC}"
    else
      echo -e "${RED}sudo is not available. Please install lolcat manually.${NC}"
    fi
  fi
}

# Function to display a welcome message with figlet and lolcat
welcome_message() {
  figlet "SIEM & HIDS Setup" | lolcat
  echo -e "${GREEN}This script will help you set up a security monitoring environment.${NC}"
  echo "It includes the following components:"
  echo "1. SIEM (Elasticsearch, Kibana, Filebeat)"
  echo "2. NIDS (Suricata)"
  echo "3. HIDS (Wazuh Manager)"
  echo "The SIEM will be installed with Elasticsearch version 7.17.13 and Wazuh version 4.5, as they were compatible during the script creation."
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
  total_ram=$(free -m | awk '/^Mem:/{print $2}')
  available_disk_space=$(df -h / | awk 'NR==2{print "Available Disk Space: " $4}')

  echo "Checking Requirements" | lolcat
  echo "Total RAM: ${total_ram} MB" | lolcat
  echo "${available_disk_space}" | lolcat

  if [ "$total_ram" -lt 4096 ]; then
    echo "Warning: Not Enough RAM." | lolcat
    read -p "Do you want to continue with the installation? (y/n): " continue_choice
    if [ "$continue_choice" != "y" ]; then
      figlet "Setup Aborted" | lolcat
      exit 1
    fi
  fi
}

# Main function to start the setup process
main() {
  check_root_privileges
  check_prerequisites
  check_and_install_lolcat
  welcome_message
  check_system_requirements

  read -p "Do you want to proceed with the setup? (y/n): " choice

  if [ "$choice" != "y" ]; then
    figlet "Setup Aborted" | lolcat
    exit 1
  fi

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
}

# Execute the main function
main
