#!/bin/bash
zenity --info  --text "This Script is used to install ZoneMinder CCTV system ; if you are ever prompted to enter your password please do so"
zenity --question --text "Are you sure you want to Install Zoneminder?" --no-wrap --ok-label "Yes" --cancel-label "No"
if [[ $? -eq 1 ]]
then exit 0
fi
sudo dnf install nano -y
sudo dnf install sed -y
sleep 5
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install epel-release -y
sudo dnf install dnf-plugins-core -y
sudo dnf config-manager --set-enabled PowerTools
sleep 5
dnf install zoneminder-httpd -y
sudo dnf install mariadb-server -y
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
sudo dnf install mod_ssl -y 
sudo systemctl enable httpd
sudo systemctl start httpd
sudo se systemctl enable zoneminder
sudo systemctl start zoneminder
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sed -i 's/enforcing/disabled/g' /etc/selinux/config
read -p "Congratulations! ZoneMinder Has Successfully Been Installed to Your PC! Please go to http://youripaddress/zm after reboot to go to the Zoneminder Web Interface"
read -p "Press any key to Continue ..."
read -p "Press [Enter] key to reboot..."
read -p "Press any key to Continue ..."
echo GOING TO REBOOT!
sleep 5
echo REBOOTING!
reboot

