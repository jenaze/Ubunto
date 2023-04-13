# bash <(curl -Ls https://raw.githubusercontent.com/jenaze/Ubunto/master/http.sh)
REQUIRED_PKG="apache2"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
#echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

cat <<EOF > /var/www/html/index.html
ok
EOF

sudo systemctl restart apache2
