#!/bin/bash

# Define the speedtest server URL
# 
read -p 'Enter Float ip : ' sv_ip

if [[ $sv_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  IFS=. read -r i1 i2 i3 i4 <<< "$sv_ip"
  if [[ $i1 -gt 255 || $i2 -gt 255 || $i3 -gt 255 || $i4 -gt 255 ]]; then
    echo "Invalid IP address: values must be between 0 and 255"
	exit 1
  fi
else
  echo "Invalid IP address: format must be x.x.x.x where x is a number between 0 and 255"
  exit 1
fi


echo -e "\033[33mSelect server \033[0m"
echo -e "\033[36m 1)\033[37m Irancell \033[0m"
echo -e "\033[36m 2)\033[37m Mci \033[0m"
read -p 'Enter Number : ' server_select



# Define the speedtest server URL
case $server_select in
  1)
    #echo "irancell"
	myurl="speedtest1.irancell.ir:8080"
    ;;
  2)
    #echo "mci"
	myurl="speedtestapp.mci.ir:8080"
    ;;
  *)
    echo -e "\033[31m Server Wrong \033[0m"
	exit 1;
    ;;
esac
speedtest_server="http://"$myurl"/download"
ping_server="http://"$myurl"/"

sudo ip addr add $sv_ip dev eth0 &> /dev/null


# Define the network interface to use
interface=$sv_ip

# Define the number of test iterations
iterations=5

# Measure the average download speed
download_speed=0
for i in $(seq 1 $iterations); do
  download=$(curl --interface $interface -o /dev/null $speedtest_server -w "%{speed_download}\n" -s)
  download_speed=$(echo "scale=2; ($download_speed + $download) / 2" | bc)
done
download_speed_mbps=$(echo "scale=2; $download_speed / 1048576" | bc)

# Measure the average upload speed
upload_server="http://"$myurl"/upload"
upload_speed=0
for i in $(seq 1 $iterations); do
  upload=$(curl --interface $interface -o /dev/null --upload-file /dev/zero $upload_server -w "%{speed_upload}\n" -s)
  upload_speed=$(echo "scale=2; ($upload_speed + $upload) / 2" | bc)
done
upload_speed_mbps=$(echo "scale=2; $upload_speed / 1048576" | bc)

# Measure the average ping time
ping_time=0
for i in $(seq 1 $iterations); do
  response_time=$(curl --interface $interface -o /dev/null --silent --head --write-out '%{time_connect}\n' $ping_server -s)
  ping_time=$(echo "scale=2; ($ping_time + $response_time) / 2" | bc)
done
ping_time_ms=$(echo "scale=2; $ping_time * 1000" | bc)

# Display the results
#echo $sv_ip" Average download speed: $download_speed_mbps Mbps"
echo $sv_ip" Average upload speed: $upload_speed_mbps Mbps"
echo $sv_ip" Average ping time: $ping_time_ms ms"
sudo ip addr del $sv_ip dev eth0 &> /dev/null
