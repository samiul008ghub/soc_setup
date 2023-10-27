# Security Setup Script

This script is designed to automate the installation of a Security Information and Event Management (SIEM) system along with  Network-based Intrusion Detection System (NIDS) and Host-based Intrusion Detection System (HIDS). The script includes the following components:

1. SIEM (Elasticsearch, Kibana and Filebeat Version: 7.17.13)
2. HIDS (Wazuh Manager Version: 4.5)
3. NIDS (Suricata)

## System Requirements

Before running the script, please ensure that your system meets the minimum requirements:

- Minimum 4GB of RAM
- Minimum 20GB of free disk space

If your system doesn't meet these requirements, the script will issue a warning and allow you to proceed at your own risk.

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/samiul008ghub/soc_tools_scripts/

2. Navigate to the repository's directory:
   ```bash
   cd soc_tools_scripts
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

   

