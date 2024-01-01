# bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/addip2.sh)

#!/bin/bash
read -p 'enter IP(ex:ip/sub) : ' IP_ADDRESS

# File to modify
file_path="/etc/netplan/50-cloud-init.yaml"

# Backup the original file
cp "$file_path" "$file_path.bak2"
    sed -i "/set-name: ens3/,/version: 2/{//!d}" "$file_path"
    sed -i "/set-name: ens3/ a\ \ \ \ \ \ \ \ \ \ \ \ addresses:\n\ \ \ \ \ \ \ \ \ \ \ \ - $IP_ADDRESS" "$file_path"

# Apply the new network configuration
sudo netplan apply
