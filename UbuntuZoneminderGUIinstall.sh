#!/bin/bash
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ Zoneminder Install Script ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ 
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ by @justaCasualCoder ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------‎ 
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ 
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ 
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ 
zenity --info --text "This Script MUST be run as root!"
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi
zenity --info  --text "This Script is used to install ZoneMinder CCTV system ; if you are ever prompted to enter your password please do so"
zenity --question --text "Are you sure you want to Install Zoneminder?" --no-wrap --ok-label "Yes" --cancel-label "No"
if [[ $? -eq 1 ]]
then exit 0
fi
password=$(zenity --password --text "(Please enter your current password)")
sudo ufw allow 80
sudo ufw allow 443
apt update -y
# Update Respitories
apt upgrade -y
# Update The System
apt install apache2 -y
sudo ufw allow in "Apache"
apt install mysql-server -y
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '$password';" >> /tmp/temp.txt
sudo mysql -u root  <  /tmp/temp.txt
sleep 5
sudo rm /tmp/temp.txt
zenity --info --text "Now we are going to secure the mysql installation ; Please Complete the folowing prompt"
sudo mysql_secure_installation
sed -i 25 a "define( 'ZM_TIMEZONE', 'America/Chicago' );" /usr/share/zoneminder/www/includes/config.php
sudo apt install php libapache2-mod-php php-mysql -y
sudo add-apt-repository ppa:iconnor/zoneminder-1.36 -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
rm /etc/mysql/my.cnf 
cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf
mysql -uroot -p < /usr/share/zoneminder/db/zm_create.sql
mysql -uroot -p -e "grant lock tables,alter,drop,select,insert,update,delete,create,index,alter routine,create routine, trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
sudo systemctl restart mysql
apt-get install zoneminder -y
chmod 740 /etc/zm/zm.conf
chown root:www-data /etc/zm/zm.conf
chown -R www-data:www-data /usr/share/zoneminder/
a2enmod cgi
a2enmod rewrite
a2enconf zoneminder
a2enmod expires
a2enmod headers
sudo systemctl enable zoneminder
sudo systemctl start zoneminder
sudo zmupdate.pl -f
sudo systemctl reload apache2
echo " 

    Open up a browser and go to http://hostname_or_ip/zm - should bring up ZoneMinder Console

    (Optional API Check)Open up a tab in the same browser and go to http://hostname_or_ip/zm/api/host/getVersion.json

        If it is working correctly you should get version information similar to the example below:

        {
            "version": "1.29.0",
            "apiversion": "1.29.0.1"
        }

"
echo Congratulations! Your installation is complete!
sleep 10
