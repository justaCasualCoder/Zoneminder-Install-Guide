#!/bin/bash
echo This Script is used to install ZoneMinder CCTV system : if you are ever prompted to enter your password please do so :
read -p "Press [Enter] key to Install ZoneMinder CCTV" 
read -p "Press any key to Start ..."
sudo yum install nano
sleep 5
sudo yum install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo yum install epel-release
sudo yum install yum-plugins-core
sudo yum config-manager --set-enabled PowerTools
sleep 5
yum install zoneminder-httpd
sudo yum install mariadb-serverhe 
systemctl enable mariadb
systemctl start  mariadb.service
echo 
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
echo "please add the folowing to line 25 ( press enter and put this in the new line)

define( 'ZM_TIMEZONE', 'America/Chicago' );"

read -p "Press [Enter] key to open zm config..."
read -p "Press any key to resume ..."
sudo nano /usr/share/zoneminder/www/includes/config.php
sudo ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
sudo yum install mod_ssl -y 
sudo systemctl enable httpd
sudo systemctl start httpd
sudo se systemctl enable zoneminder
sudo systemctl start zoneminder
sudo systemctl disable firewalld
sudo systemctl stop firewalld
echo please edit /etc/selinux/config and replace enforcing to disabled
read -p "Press [Enter] key to open the SElinux config file..."
read -p "Press any key to resume
sudo nano /etc/selinux/config
read -p "Congratulations! ZoneMinder Has Successfully Been Installed to Your PC! Please go to http://youripaddress/zm after reboot to go to the Zoneminder Web Interface"
read -p "Press any key to Continue ..."
read -p "Press [Enter] key to reboot..."
read -p "Press any key to Continue ..."
echo GOING TO REBOOT!
sleep 5
echo REBOOTING!
reboot

