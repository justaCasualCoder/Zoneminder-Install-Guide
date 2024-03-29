#!/bin/bash
figlet Made by @justacasualcoder
zenity --info --text " This script  assumes you have already installed sudo and are running this script as a user with root privilages"
zenity --info  --text "This Script is used to install ZoneMinder CCTV system ; if you are ever prompted to enter your password please do so"
zenity --question --text "Are you sure you want to Install Zoneminder?" --no-wrap --ok-label "Yes" --cancel-label "No"
if [[ $? -eq 1 ]]
then exit 0
fi
read -p "This Script MUST be run as root!"
read -p "press enter to continue"
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi
sudo apt update
sudo apt upgrade
sudo apt install apache2 apache2-utils -y
sudo systemctl enable apache2
sudo systemctl start apache2
sudo apt-get install mariadb-server -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation
sudo apt install php php-cli php-mysql libapache2-mod-php php-gd php-xml php-curl php-common -y
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo ufw reload
sudo echo "# ZoneMinder repository" >> /etc/apt/sources.list
sudo echo "deb https://zmrepo.zoneminder.com/debian/release stretch/" >> /etc/apt/sources.list
sudo apt install apt-transport-https
wget -O - https://zmrepo.zoneminder.com/debian/archive-keyring.gpg | sudo apt-key add -
sudo apt update
sudo apt install zoneminder
sudo systemctl enable zoneminder.service
sudo a2enconf zoneminder
sudo a2enmod rewrite
sudo a2enmod cgi # this is done automatically when installing the package.
sudo sed -i "s/;date.timezone =/date.timezone = $(sed 's/\//\\\//' /etc/timezone)/g" /etc/php/7.0/apache2/php.ini
zmupdate.pl -f
echo " If the above command did not succesfully execute , please type in the following;                                    
sudo -s
zmupdate.pl -f
exit"
sudo systemctl reload apache2
sudo systemctl start zoneminder
sudo echo "You are now ready to go with ZoneMinder. Open a browser and type either localhost/zm one the local machine or {IP-OF-ZM-SERVER}/zm if you connect from a remote computer."
