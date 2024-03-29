#!/bin/bash

## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/count_ip.sh)

# Check for root privilege
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Check if sqlite3 is installed
if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 not found. Installing..."
  apt-get -y install sqlite3
fi

# Define a function for the query
count_ips() {
  sqlite3 -line /etc/x-ui/x-ui.db "SELECT *, LENGTH(ips) - LENGTH(REPLACE(ips, ',', '')) + 1 as ip_count FROM inbound_client_ips WHERE LENGTH(ips) - LENGTH(REPLACE(ips, ',', '')) + 1 > 2"
}

# Run the query
count_ips
