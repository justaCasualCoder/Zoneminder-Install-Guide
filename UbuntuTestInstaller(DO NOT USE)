#!/bin/bash

# Set the name of the software package
package_name="Zoneminder"

# Display a message asking the user if they want to install the package
zenity --question --text="Do you want to install $package_name?"

# If the user clicks "Yes", proceed with the installation
if [ $? -eq 0 ]; then
  # Display a progress bar while the package is being installed
  zenity --progress --pulsate --title="Installing $package_name" --text="Please wait while $package_name is being installed..." --auto-close &
  
  # Install the package (replace this with the actual installation commands for your package)
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
  
  # Wait for the progress bar to close before continuing
  wait
  
  # Display a message indicating that the installation was successful
  zenity --info --title="Installation Complete" --text="$package_name has been successfully installed in $install_dir"
else
  # If the user clicks "No", display a message indicating that the installation was cancelled
  zenity --warning --title="Installation Cancelled" --text="The installation of $package_name was cancelled."
fi

