# bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/addip.sh)

#!/bin/bash
read -p 'enter IP : ' IP_ADDRESS
NETWORK_INTERFACE=$(ip addr show | grep '^[0-9]' | grep -v ' lo:' | awk '{print $2}')
echo "ip addr add $IP_ADDRESS/32 dev $NETWORK_INTERFACE" | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local
sudo reboot
