## bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/hasan.sh)

#sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#sudo passwd root

read -p 'enter Iran server ip address : ' ip_iran
read -p 'enter Out server ip address : ' ip_exter

sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination $ip_iran
#sudo iptables -t nat -A PREROUTING -p icmp --icmp-type 8 -j DNAT --to-destination $ip_iran

#sudo iptables -A FORWARD -p icmp --icmp-type 8 -j ACCEPT --to-destination $ip_iran
sudo iptables -t nat -A PREROUTING -j DNAT --to-destination $ip_exter
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
sudo echo 1 >> /proc/sys/net/ipv4/ip_forward
