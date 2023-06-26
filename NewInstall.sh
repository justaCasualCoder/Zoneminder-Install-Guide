#!/bin/bash
RED='\033[0;31m'
# Current working systems - OpenSuSE , Ubuntu , Fedora , Arch Linux , Debian , Alpine Linux
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
    DISTRO=${DISTRO%\"}  # Remove leading double quote
    DISTRO=${DISTRO#\"}  # Remove trailing double quote
    echo "Detected Red Hat-based distribution: $DISTRO"
# Check if the system uses Pacman package manager
elif command -v pacman > /dev/null 2>&1; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    echo "Detected Arch-based distribution: $DISTRO"
    DISTRO="Arch Linux"
# Check if the system uses Zypper package manager
elif command -v zypper > /dev/null 2>&1; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    echo "Detected SUSE-based distribution: $DISTRO"
    DISTRO="OpenSuSE"
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
EOF
echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list
apt update && apt -t bullseye-backports install zoneminder -y
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod cgi
echo "Fixing API.."
chown -R www-data:www-data /usr/share/zoneminder
cat << END >> /etc/apache2/conf-available/zoneminder.conf
<Directory /usr/share/zoneminder/www/api>
    AllowOverride All
</Directory>
END
chown www-data:www-data /etc/apache2/conf-available/zoneminder.conf
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
EOF
echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list
apt update && apt -t bullseye-backports install zoneminder -y
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
echo "Fixing API.."
chown -R www-data:www-data /usr/share/zoneminder
cat << END >> /etc/apache2/conf-available/zoneminder.conf
<Directory /usr/share/zoneminder/www/api>
    AllowOverride All
</Directory>
END
chown www-data:www-data /etc/apache2/conf-available/zoneminder.conf
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
Alpine_Install() {
cat > /etc/apk/repositories << EOF
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community
EOF
apk update
apk add apache2 php81-apache2
apk add php8-pdo php8-pdo_mysql mariadb mysql-client
apk add zoneminder
service mariadb setup
service mariadb start
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
apk add php81-fpm php81-pdo php81-pdo_mysq
sed -i 's/Options None/Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch/' /etc/apache2/httpd.conf
service mariadb start
service apache2 start
service zoneminder start
echo "ZM Should be all up and running! Access at "$(ip -oneline -family inet address show | grep "${IPv4bare}/" |  awk '{print $4}' | awk 'END {print}' | sed 's/.\{3\}$//')/zm""
}
TrueNas_Install() {
export ASSUME_ALWAYS_YES=yes
pkg install apache24
sysrc apache24_enable="YES"
service apache24 start
pkg install mariadb106-server-10.6.13
sysrc mysql_enable="YES"
service mysql-server start
pkg install php82 php82-mysqli mod_php82
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
rehash
cat << EOF >> /usr/local/etc/apache24/modules.d/001_mod-php.conf
<IfModule dir_module>
    DirectoryIndex index.php index.html
    <FilesMatch "\.php$">
        SetHandler application/x-httpd-php
    </FilesMatch>
    <FilesMatch "\.phps$">
        SetHandler application/x-httpd-php-source
    </FilesMatch>
</IfModule>
EOF
apachectl restart
echo "<?php phpinfo(); ?>" >> "/usr/local/www/apache24/data/info.php"
pkg install zoneminder
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
}
Arch_Install() {
if ! id -u temp >/dev/null 2>&1; then
    useradd -g users temp
    PASS=$(date | md5sum | cut -c1-8)
    read -p "Remember! Temp Pass is $PASS"
    echo temp:${PASS} | chpasswd
    echo "temp ALL=(ALL:ALL) ALL" >> /etc/sudoers
    mkdir /home/temp/
    chown -R temp:users /home/temp
fi
sudo pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo "Yay Is already installed!"
else
pacman -S git --noconfirm
pacman -S fakeroot --noconfirm
pacman -S make --noconfirm
cd /opt
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
chown -R temp:users ./yay-bin
cd yay-bin
sudo -u  temp -- /bin/makepkg -si --noconfirm
fi
pacman -S --noconfirm apache mysql sudo
pacman -S --noconfirm mysql
systemctl start mysqld
systemctl start httpd
pacman -S --noconfirm php php-apache php-fpm
echo "Include conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf
sed -i 's/^LoadModule mpm_event_module modules\/mod_mpm_event\.so/#&/' /etc/httpd/conf/httpd.conf
sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork\.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf/httpd.conf
sed -i '/^#LoadModule/s/$/\nLoadModule php_module modules\/libphp.so\nAddHandler php-script .php/' /etc/httpd/conf/httpd.conf
sed -i '$ a Include conf\/extra\/php_module.conf' /etc/httpd/conf/httpd.conf
systemctl restart httpd
su temp -- yay -S zoneminder
echo "Include conf/extra/zoneminder.conf" >> /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule proxy_module modules/mod_proxy.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule rewrite_module modules/mod_rewrite.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule cgid_module modules/mod_cgid.so\)|\1|' /etc/httpd/conf/httpd.conf
sudo sed -i '$ a\LoadModule cgid_module modules/mod_cgid.so' /etc/httpd/conf/httpd.conf
systemctl restart httpd
mysql_install_db --user=mysql --basedir=/usr/ --ldata=/var/lib/mysql/
cat << EOF | mysql
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
sed -i '$ d' /etc/sudoers
userdel temp
systemctl start httpd
systemctl start mysqld
systemctl start php-fpm
systemctl start zoneminder
systemctl enable httpd
systemctl enable mysqld
systemctl enable php-fpm
systemctl enable zoneminder
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
EOF
add-apt-repository universe
apt update && apt install zoneminder -y
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
# Run this after updates + reinstall php + restart mysql,apache2,and zoneminder
chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
adduser www-data video
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
systemctl restart apache2
systemctl enable zoneminder
systemctl enable apache2
systemctl enable mysql
echo "Fixing API.."
chown -R www-data:www-data /usr/share/zoneminder
cat << END >> /etc/apache2/conf-available/zoneminder.conf
<Directory /usr/share/zoneminder/www/api>
    AllowOverride All
</Directory>
END
chown www-data:www-data /etc/apache2/conf-available/zoneminder.conf
}
suse_Install() {
zypper addrepo https://download.opensuse.org/repositories/security:zoneminder/openSUSE_Tumbleweed/security:zoneminder.repo
zypper --gpg-auto-import-keys refresh
zypper -n refresh
zypper -n install apache2 php php-mysql php-gd php-mbstring apache2-mod_php8 mariadb mariadb-client ZoneMinder php8-intl
systemctl start apache2
systemctl start mariadb
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod php8
cat << EOF | mariadb
BEGIN;
CREATE DATABASE zm;
CREATE USER zm_admin@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zm_admin@localhost;
FLUSH PRIVILEGES;
EOF
mariadb -u zm_admin -pzmpass < /usr/share/zoneminder/db/zm_create.sql
systemctl restart apache2 mariadb
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
}
Fedora_Install() {
dnf install nano sed httpd mariadb-server php  php-common php-mysqlnd -y
systemctl start httpd
systemctl start mariadb
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install zoneminder-httpd -y
ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
dnf install mod_ssl -y
mysql < /usr/share/zoneminder/db/zm_create.sql
cat << EOF | mysql
BEGIN;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
setenforce 0
# Temporary fix to make gui work - with proparly fix in future
mkdir /usr/share/zoneminder/www/skins/classic/css/fonts 
ln /usr/share/zoneminder/www/fonts/* /usr/share/zoneminder/www/skins/classic/css/fonts/
systemctl enable httpd
systemctl restart httpd
systemctl enable zoneminder
systemctl start zoneminder
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd  --add-service=http --add-service=https
zmupdate.pl -f
}
echo -n "Are you sure you want to install Zoneminder? [y/n]: " ; read yn
if [ $yn = y ]; then
    case $DISTRO in
        "Debian"|"Debian Linux") Debian_Install ;;
        "Fedora Linux"|"Fedora") Fedora_Install ;; 
        "Ubuntu Linux"|"Ubuntu") Ubuntu_Install ;;
        "Termux"|"Android") termux_install ;; 
        "Arch"|"Arch Linux") Arch_Install ;;
        "Alpine Linux"|"Alpine") Alpine_Install ;;
        "OpenSuSE"|"OpenSuSe") suse_Install ;;
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