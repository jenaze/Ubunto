#!/bin/bash

##################### Ftp Section ######################
## wget https://raw.githubusercontent.com/jenaze/Ubunto/master/fakeup.sh
## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/fakeup.sh)
## chmod +x fakeup.sh
## touch /tmp/fakeup.lock
## */2 * * * * /dl/1/fakeup.sh >> /dl/1/my.log 2>&1

addr=217.xxx.xxx.xxx
username=xxxxxxxxxx
password=xxxxxxxxxx

##################### File Section ######################
name=$RANDOM
x=3
y=50
size=$[ $x + $name % ($y + 1 - $x) ]
##################### Upload Section ######################
ExteraDownloadMb = 0
ExteraUploadMb = 0
UploadEx = 10 //1X10


if [ -f /tmp/fakeup.lock ]; then
    exit 0
else
    touch /tmp/fakeup.lock
fi



# Get RX and TX statistics (in bytes) for eth0 interface and save to variables
RX_bytes=$(ifconfig eth0 | awk '/RX packets/ {print $5}')
TX_bytes=$(ifconfig eth0 | awk '/TX packets/ {print $5}')

# Convert RX and TX statistics from bytes to megabytes (MB)
RX=$(echo "scale=2; $RX_bytes/1048576" | bc -l)
TX=$(echo "scale=2; $TX_bytes/1048576" | bc -l)

RX=$(echo "$RX+$ExteraDownloadMb" | bc)
TX=$(echo "$TX+$ExteraUploadMb" | bc)

SDL=$(echo "$RX*$UploadEx" | bc)


echo "download=$RX"
echo "upload=$TX"
echo "should_upload=$SDL"

if awk 'BEGIN {exit !('"$SDL"' > '"$TX"')}'
then
randomSizeUpload=true
uploadspeed=3m

MaximumRandomSpeed=10
if $randomSizeUpload
then
uploadspeed=$[ 2 + $name % ($MaximumRandomSpeed + 1 - 2) ]m
echo "Set UploadSpeed To "$uploadspeed
fi

truncate -s $size'MB' $name.zip
echo $name".zip ===> "$size"Mb"
echo $name".zip uploading..."
curl --limit-rate $uploadspeed -T /dl/1/$name.zip ftp://$addr --user $username:$password &> /dev/null
curl -v -u $username:$password ftp://$addr -Q 'DELE '$name'.zip' &> /dev/null
rm -rf $name.zip
echo "Done"
echo ""
    exit 0
fi
# Once the script has finished running, remove the lock file
rm /tmp/fakeup.lock
