#!/bin/bash
sudo dnf install nano sed httpd mysql mysql-server php php-mysql -y
sudo service httpd start
sudo service mysqld start
mysql_secure_installation
sudo chkconfig httpd on sudo chkconfig mysqld on
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install epel-release dnf-plugins-core -y
sudo dnf config-manager --set-enabled PowerTools
dnf install zoneminder-httpd mod-ssl-y
mysql -u root -p < /usr/share/zoneminder/db/zm_create.sql
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
END;
EOF
mysqladmin -uroot -p reload
sleep 5
setenforce 0
sed -i 25 a "define( 'ZM_TIMEZONE', 'America/Chicago' );" /usr/share/zoneminder/www/includes/config.php
sudo ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl enable zoneminder
sudo systemctl start zoneminder
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sed -i 's/enforcing/disabled/g' /etc/selinux/config
zmupdate.pl -f
