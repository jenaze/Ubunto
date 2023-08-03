# bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/addip.sh)

#!/bin/bash
read -p 'enter IP(ex:ip/sub) : ' IP_ADDRESS

# File to modify
file_path="/etc/netplan/50-cloud-init.yaml"

# Backup the original file
cp "$file_path" "$file_path.bak"


# Check if 'addresses' key already exists in the file
if grep -q "addresses:" "$file_path"; then
    # If 'addresses' key exists, append the new IP address to the existing list
    sed -i "/addresses:/ a\ \ \ \ \ \ \ \ \ \ \ \ - $IP_ADDRESS" "$file_path"
else
    # If 'addresses' key does not exist, add the new IP address under 'ens3'
    sed -i "/set-name: ens3/ a\ \ \ \ \ \ \ \ \ \ \ \ addresses:\n\ \ \ \ \ \ \ \ \ \ \ \ - $IP_ADDRESS" "$file_path"
fi

# Apply the new network configuration
sudo netplan apply
