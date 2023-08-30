#!/bin/bash -
############################################################
# Author:         Christo Deale                  
# Date  :         2023-08-30            
# rhel9_rkhunter: Utility to scan for RHEL 9 for Malware Root
#                 Kits using RKHUNTER & email results via 
#                 mail            
############################################################
# Check if EPEL is installed
if ! rpm -q epel-release &> /dev/null; then
  echo "EPEL repository is not installed. Enabling codeready-builder-for-rhel-9-$(arch)-rpms repository..."
  sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
  echo "Installing EPEL repository..."
  sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
fi

# Check if rkhunter is installed
if ! rpm -q rkhunter &> /dev/null; then
  echo "rkhunter is not installed. Installing..."
  sudo dnf install rkhunter -y
fi

# Change rkhunter setting
sudo sed -i 's/DIAG_SCAN=no/DIAG_SCAN=yes/' /etc/sysconfig/rkhunter

# Update rkhunter database
sudo rkhunter --update && sudo rkhunter --propupd

# Run rkhunter scan
sudo rkhunter --check --rwo

# Prompt for email address and send log file
read -p "Enter your email address: " email_address
mail -s "rkhunter scan report" $email_address < "$(ls -t /var/log/rkhunter/rkhunter*.log | head -1)"
