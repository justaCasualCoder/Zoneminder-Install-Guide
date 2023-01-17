#!/bin/bash
user=$(whoami)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)
if [ -z $cprt ]; then
export cprt=0
fi
if [ $cprt != 1 ]; then
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ Zoneminder Install Script ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ by @justaCasualCoder ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
fi
export cprt=1
read -p "This Script is used to install ZoneMinder CCTV system ; if you are ever prompted to enter your password please do so"
read -p "Are you sure you want to Install Zoneminder? (Press Control-C to cancel)"
sudo yum install nano -y
sudo yum install sed -y
echo "Adding RPM Fusion Respitory"
sleep 3
sudo yum install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
sudo yum install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm -y
sudo yum install epel-release -y
sudo yum install yum-plugins-core -y
sudo yum config-manager --set-enabled PowerTools
sudo subscription-manager repos --enable "codeready-builder-for-rhel-8-$(uname -m)-rpms"
sleep 5
echo "Installing Zoneminder"
sudo yum install zoneminder-httpd -y
echo "Installing MariaDB and securing install"
sudo yum install mariadb-server -y
systemctl enable mariadb
systemctl start  mariadb.service
sleep 3
mysql_secure_installation
sleep 10
mysql -u root -p < /usr/share/zoneminder/db/zm_create.sql
mysql -u root -p -e "CREATE USER 'zmuser'@'localhost' \
                          IDENTIFIED BY 'zmpass';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON zm.* TO \
                         'zmuser'@localhost;"
mysqladmin -uroot -p reload
sleep 5
setenforce 0
sed -i 25 a "define( 'ZM_TIMEZONE', 'America/Chicago' );" /usr/share/zoneminder/www/includes/config.php
sudo ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
sudo yum install mod_ssl -y
sudo systemctl enable httpd
sudo systemctl start httpd
sudo se systemctl enable zoneminder
sudo systemctl start zoneminder
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sed -i 's/enforcing/disabled/g' /etc/selinux/config
zmupdate.pl -f
echo " If the above command did not succesfully execute , please type in the following; ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
sudo -s
zmupdate.pl -f
exit"
read -p "Congratulations! ZoneMinder Has Successfully Been Installed to Your PC! Please go to http://youripaddress/zm after reboot to go to the Zoneminder Web Interface"
read -p "Press any key to Continue ..."
read -p "Press [Enter] key to reboot..."
read -p "Press any key to Continue ..."
echo GOING TO REBOOT!
sleep 5
echo REBOOTING!
reboot
