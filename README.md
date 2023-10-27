# Automated SOC Components Setup Script

## Overview

This script automates the setup of a comprehensive security monitoring environment, including a Security Information and Event Management (SIEM) system, Host-based Intrusion Detection System (HIDS), and Network-based Intrusion Detection System (NIDS) on a single machine. It streamlines the installation process, making it accessible to users with different levels of technical expertise.

**Note:** This script is intended to install all the components on a single machine, meaning the same box will have the SIEM, NIDS, and HIDS core components.

## Components

The script facilitates the installation of the following security components:

1. **SIEM (Security Information and Event Management):** This component combines Elasticsearch, Kibana, and Filebeat to provide a powerful platform for monitoring and analyzing security events in your environment.

2. **HIDS (Host-based Intrusion Detection System):** The script installs the Wazuh Manager, an open-source HIDS. It aids in monitoring, detecting, and responding to security threats on individual hosts.

3. **NIDS (Network-based Intrusion Detection System):** Suricata, a high-performance NIDS, is configured to help protect your network from intrusions and suspicious activities. **Note:** Suricata will monitor the local interface of the machine where it is installed. To monitor the entire network traffic, it should receive traffic from a TAP device or a SPAN port.
## System Requirements

Before running the script, please ensure that your system meets the minimum requirements:

- Minimum 4GB of RAM
- Minimum 20GB of free disk space

If your system doesn't meet these requirements, the script will issue a warning and allow you to proceed at your own risk.

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/samiul008ghub/soc_setup/

2. Navigate to the repository's directory:
   ```bash
   cd soc_setup
3. Make the setup_script.sh executable:
   ```bash
   chmod +x setup_script.sh
4. Execute the setup_script.sh:
   ```bash
   ./setup_script.sh
5. Follow the on-screen prompts to choose which components you want to install and continue with the setup.

## Component Details

SIEM (Elasticsearch, Kibana, Filebeat): The SIEM setup includes Elasticsearch version 7.17.13 and the latest compatible versions of Kibana and Filebeat.

HIDS (Wazuh Manager): The setup includes the installation of Wazuh Manager version 4.5.

NIDS (Suricata): The script installs Suricata for Network-based Intrusion Detection.

## Warning
Please be cautious when running the script and ensure you have a backup of your data if you are installing these security components on a production system.

   

