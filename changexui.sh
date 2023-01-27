


#!/bin/bash

 
 ## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/changexui.sh)
 
REQUIRED_PKG="sqlite3"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
#echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi


 if [ "$1" -eq  "0" ]
   then
     read -p 'old ip : ' old_ip
 else
     old_ip = $1
 fi
 
  if [ "$2" -eq  "0" ]
   then
     read -p 'New Ip : ' new_ip
 else
     new_ip = $2
 fi
 



sudo sqlite3 -line /etc/x-ui/x-ui.db "UPDATE inbounds SET listen = '"$new_ip"'"
sudo sed -i 's/'$old_ip'/'$new_ip'/' /usr/local/x-ui/bin/config.json
sudo x-ui restart
