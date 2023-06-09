#!/bin/bash
RED='\033[0;31m'
# Known OS'es - Debian,Centos,Fedora,Ubuntu
[[ $(ps -ef|grep -c com.termux ) -gt 1 ]] && echo "Wow! Your on Termux!" && DISTRO="Termux"
install_evserver() {
apt install git -y
git clone https://github.com/zoneminder/zmeventnotification.git
cd zmeventnotification
sudo perl -MCPAN -e "install Crypt::MySQL"
sudo perl -MCPAN -e "install Config::IniFiles"
sudo perl -MCPAN -e "install Crypt::Eksblowfish::Bcrypt"
apt-get install libjson-perl -y
apt-get install liblwp-protocol-https-perl
mkdir -R /etc/zm/apache2/ssl/
echo "===> Generating SSL Keys.."
openssl req -x509 -nodes -days 4096 -newkey rsa:2048 -keyout /etc/zm/apache2/ssl/zoneminder.key -out /etc/zm/apache2/ssl/zoneminder.crt
./install.sh
echo "Install Complete! - You still have to edit /etc/zm/secrets.ini to contain your IP address and admin password etc"
}
# Check if the system uses Debian package manager
if command -v apt-get > /dev/null 2>&1; then
    DISTRO=$(lsb_release -si)
    echo "Detected Debian-based distribution: $DISTRO"
# Check if the system uses Red Hat package manager
elif command -v yum > /dev/null 2>&1; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    echo "Detected Red Hat-based distribution: $DISTRO"
# Check if the system uses Pacman package manager
elif command -v pacman > /dev/null 2>&1; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    echo "Detected Arch-based distribution: $DISTRO"
# Check if the system uses Zypper package manager
elif command -v zypper > /dev/null 2>&1; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    echo "Detected SUSE-based distribution: $DISTRO"
# Check if the system uses Alpine package manager
elif command -v apk > /dev/null 2>&1; then
    DISTRO="Alpine Linux"
    echo "Detected Alpine Linux distribution"
    echo "Installing On Alpine may be a little tricky..."
# If all else fails, fall back to reading /etc/issue file
else
    DISTRO=$(cat /etc/issue | awk '{print $1}')
    echo "Unable to detect package manager, falling back to /etc/issue: $DISTRO"
fi
Debian_Install() {
apt update
apt install gpgv
apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 -y
systemctl start mariadb
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
END;
EOF
echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list
apt update && apt -t bullseye-backports install zoneminder
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod cg
echo "Fixing API.."
cd /etc/apache2/conf-enabled/
mv zoneminder.conf zoneminder.conf.bak  
wget "https://raw.githubusercontent.com/justaCasualCoder/Zoneminder-Termux/main/zoneminder.conf"
chown www-data:www-data zoneminder.conf
systemctl reload apache2
}
termux_install() {
apt update
apt install gpgv
apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 -y
/etc/init.d/mariadb start
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
END;
EOF
echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list
apt update && apt -t bullseye-backports install zoneminder
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
echo "Fixing API.."
cd /etc/apache2/conf-enabled/
mv zoneminder.conf zoneminder.conf.bak  
wget "https://raw.githubusercontent.com/justaCasualCoder/Zoneminder-Termux/main/zoneminder.conf"
chown www-data:www-data zoneminder.conf
cd /
sed -i 's/80/8080/g' /etc/apache2/ports.conf
/etc/init.d/mariadb restart
/etc/init.d/apache2 start
/etc/init.d/zoneminder start
echo -n "Would you like to make Zoneminder start automatically on startup? (just adds the above command to .profile) [y/n]: " ; read answer
if [ $answer == y ]; then
    echo "/etc/init.d/apache2 start" >> ~/.profile
    echo "/etc/init.d/mariadb start" >> ~/.profile
    echo "/etc/init.d/zoneminder start" >> ~/.profile
fi
cd /
wget https://raw.githubusercontent.com/justaCasualCoder/Zoneminder-Termux/main/initzm.sh
echo "To start it you can run this command at the / dir : bash initzm.sh"
}
Ubuntu_Install() {
apt update
apt install gpgv
apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 -y
systemctl start mariadb
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
END;
EOF
add-apt-repository universe
apt update && apt install zoneminder
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
# Run this after updates + reinstall php + restart mysql,apache2,and zoneminder
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
echo "Fixing API.."
cd /etc/apache2/conf-enabled/
mv zoneminder.conf zoneminder.conf.bak  
wget "https://raw.githubusercontent.com/justaCasualCoder/Zoneminder-Termux/main/zoneminder.conf"
chown www-data:www-data zoneminder.conf
}
Fedora_Install() {
#!/bin/bash
sudo dnf install nano sed httpd mysql mysql-server php php-mysql -y
sudo service httpd start
sudo service mysqld start
sudo chkconfig httpd on 
sudo chkconfig mysqld on
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install zoneminder-httpd mod-ssl -y
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
setenforce 0
sed -i 25 a "define( 'ZM_TIMEZONE', 'America/Chicago' );" /usr/share/zoneminder/www/includes/config.php
sudo ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl enable zoneminder
sudo systemctl start zoneminder
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sed -i 's/enforcing/disabled/g' /etc/selinux/config
zmupdate.pl -f
}
echo -n "Are you sure you want to install Zoneminder? [y/n]: " ; read yn
if [ $yn = y ]; then
    case $DISTRO in
        "Debian"|"Debian Linux") Debian_Install ;;
        "Fedora Linux"|"Fedora") Fedora_Install ;; 
        "Ubuntu Linux"|"Ubuntu") Ubuntu_Install ;;
        "Termux"|"Android") termux_install ;; 
esac
fi
if [ $yn != y ]; then
    printf "${RED}Aborted\n"
    exit 0
fi
echo -n "Would you like to install ZM Event Server? This only works on Debian.. [y/n]: " ; read yn
if [ $yn = y ]; then
    echo "===> Installing..."
    install_evserver
fi
echo "You can now connect to Zoneminder at $(ip -oneline -family inet address show | grep "${IPv4bare}/" |  awk '{print $4}' | awk 'END {print}' | sed 's/.\{3\}$//')/zm"