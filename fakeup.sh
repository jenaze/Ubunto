#!/bin/bash

##################### Ftp Section ######################
## wget https://raw.githubusercontent.com/jenaze/Ubunto/master/fakeup.sh
## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/fakeup.sh)
## chmod +x fakeup.sh
## touch /tmp/fakeup.lock
## */2 * * * * /dl/1/fakeup.sh >> /dl/1/my.log 2>&1

#!/bin/bash

readonly ADDR=217.144.107.50
readonly USERNAME=sid@novinlike.ir
readonly PASSWORD=mHm09350912
readonly UPLOAD_EX=10  # 1X10
readonly EXTERNAL_DOWNLOAD_MB=0
readonly EXTERNAL_UPLOAD_MB=0
readonly MAXIMUM_RANDOM_SPEED=10
readonly UPLOAD_SPEED_DEFAULT=3m

name=$RANDOM
x=3
y=50
size=$(( x + name % (y + 1 - x) ))

if [ -f /tmp/fakeup.lock ]; then
    exit 0
else
    touch /tmp/fakeup.lock
fi

# Get RX and TX statistics (in bytes) for eth0 interface and save to variables
rx_bytes=$(ifconfig eth0 | awk '/RX packets/ {print $5}')
tx_bytes=$(ifconfig eth0 | awk '/TX packets/ {print $5}')

# Convert RX and TX statistics from bytes to megabytes (MB)
rx=$(echo "scale=2; ${rx_bytes:6:10}/1048576 + $EXTERNAL_DOWNLOAD_MB" | bc -l)
tx=$(echo "scale=2; ${tx_bytes:6:10}/1048576 + $EXTERNAL_UPLOAD_MB" | bc -l)

sdl=$(echo "$rx*$UPLOAD_EX" | bc)

printf "download=%.2f\n" "$rx"
printf "upload=%.2f\n" "$tx"
printf "should_upload=%.2f\n" "$sdl"

if [[ $sdl > $tx ]]; then
    random_size_upload=true
    upload_speed=$UPLOAD_SPEED_DEFAULT

    if $random_size_upload; then
        upload_speed="$((2 + name % (MAXIMUM_RANDOM_SPEED + 1 - 2)))m"
        printf "Set UploadSpeed To %s\n" "$upload_speed"
    fi

    truncate -s "$size"MB /dl/1/"$name".zip
    printf "%s.zip ===> %d Mb\n" "$name" "$size"
    printf "%s.zip uploading...\n" "$name"
    curl --limit-rate "$upload_speed" -T /dl/1/"$name".zip ftp://"$ADDR" --user "$USERNAME":"$PASSWORD" &> /dev/null
    curl -v -u $username:$password ftp://$addr -Q 'DELE '$name'.zip' &> /dev/null
    rm -rf /dl/1/$name.zip
    echo "Done"
    echo ""
    exit 0
fi
# Once the script has finished running, remove the lock file
rm /tmp/fakeup.lock
