#!/bin/bash
if [ -z $cprt ]; then
export cprt=0
fi
if [ $cprt -ne 1 ]; then
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo     Zoneminder Install Script         
echo         by @justaCasualCoder     
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo               
echo               
echo               
fi
export cprt=1
read -p "This Script MUST be run as root!"
read -p "press enter to continue"
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi
echo -n "What is the password you would like to use for Mysql ( root user )? : "
# Assign input value into a variable
read password
sudo ufw allow 80
sudo ufw allow 443
nala update -y
# Update Respitories
nala upgrade -y
# Update The System
nala install apache2 -y
# Install Apache2
sudo ufw allow in "Apache"
# Allow ports 80 and 443 through UFW
nala install mysql-server -y
# Install Mysql Server
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '$password';" >> /tmp/temp.txt
sudo mysql -u root  <  /tmp/temp.txt
sudo rm /tmp/temp.txt
# Configure root password for Mysql
read -p " Now we are going to secure the mysql installation ; Please Complete the folowing prompt"
read -p "Press enter to continue"
# Secure Mysql
sudo mysql_secure_installation
# Set Timezone
sudo nala install php libapache2-mod-php php-mysql -y
# Install PHP
sudo add-apt-repository ppa:iconnor/zoneminder-1.36 -y
# Add Zoneminder Respository
sudo nala update -y
sudo nala upgrade -y
sudo apt-get dist-upgrade -y
# Upgrade and update the system
sudo rm /etc/mysql/my.cnf
cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf
mysql -uroot -p < /usr/share/zoneminder/db/zm_create.sql
mysql -uroot -p -e "grant lock tables,alter,drop,select,insert,update,delete,create,index,alter routine,create routine, trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
# Configure zmuser
sudo systemctl restart mysql
# Restart mysql
nala install zoneminder -y
sed -i '8i "define( 'ZM_TIMEZONE', 'America/Chicago' );"' /usr/share/zoneminder/www/includes/config.php
# Install Zoneminder
chmod 740 /etc/zm/zm.conf
chown root:www-data /etc/zm/zm.conf
chown -R www-data:www-data /usr/share/zoneminder/
# Change directory permissions
a2enmod cgi
a2enmod rewrite
a2enconf zoneminder
a2enmod expires
a2enmod headers
# Enable Zoneminder in Apache2 and configure modules
sudo systemctl enable zoneminder
sudo systemctl start zoneminder
# Enable and start Zoneminder
zmupdate.pl -f
# Updates Zoneminder Mysql THIS IS NEEDED!! IF IT IS NOT DONE, THEN YOU WILL JUST SEE A WHITE PAGE (OR ERROR ON GOOGLE CHROME)
echo " If the above command did not succesfully execute , please type in the following;            
sudo -s
zmupdate.pl -f
exit"
sudo systemctl reload apache2
echo "

    Open up a browser and go to http://$(ip -oneline -family inet address show | grep "${IPv4bare}/" |  awk '{print $4}' | awk 'END {print}' | sed 's/.\{3\}$//')/zm - it should bring up ZoneMinder Console

    (Optional API Check)Open up a tab in the same browser and go to http://hostname_or_ip/zm/api/host/getVersion.json

        If it is working correctly you should get version information similar to the example below:

        {
            "version": "1.32.0",
            "apiversion": "1.32.0.1"
        }

"
echo Congratulations! Your installation is complete!
read -p 'Would You like to set up remote storage over NFS?'
