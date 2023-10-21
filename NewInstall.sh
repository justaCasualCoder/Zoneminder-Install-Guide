#!/bin/bash
RED='\033[0;31m'
# Current working systems - OpenSuSE , Ubuntu , Fedora , Arch Linux , Debian , Alpine Linux
[[ $(ps -ef|grep -c com.termux ) -gt 1 ]] && echo "Wow! Your on Termux!" && DISTRO="Termux"
install_evserver() {
apt install git -y
git clone https://github.com/zoneminder/zmeventnotification.git
cd zmeventnotification || exit 1
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
    #echo "Installing On Alpine may be a little tricky..."
# If all else fails, fall back to reading /etc/issue file
else
    DISTRO=$(cat /etc/issue | awk '{print $1}')
    echo "Unable to detect package manager, falling back to /etc/issue: $DISTRO"
fi
Debian12_Install() {
# From https://wiki.zoneminder.com/Debian_12_Bookworm_with_Zoneminder_1.36.33
apt update 
apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 -y
apt install zoneminder -y
mysql -uroot  < /usr/share/zoneminder/db/zm_create.sql
mysql -uroot  -e "grant all on zm.* to 'zmuser'@localhost identified by 'zmpass';"
mysqladmin -uroot reload
chmod 640 /etc/zm/zm.conf
chown root:www-data /etc/zm/zm.conf
chown -R www-data:www-data /var/cache/zoneminder/
chmod 755 /var/cache/zoneminder/
cp /etc/apache2/conf-available/zoneminder.conf /etc/apache2/conf-available/zoneminder.conf.bak 
rm /etc/apache2/conf-available/zoneminder.conf
cat << EOF >> /etc/apache2/conf-available/zoneminder.conf
# Remember to enable cgi mod (i.e. "a2enmod cgi").
ScriptAlias /zm/cgi-bin "/usr/lib/zoneminder/cgi-bin"
<Directory "/usr/lib/zoneminder/cgi-bin">
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    AllowOverride All
    Require all granted
</Directory>


# Order matters. This alias must come first.
Alias /zm/cache "/var/cache/zoneminder"
<Directory "/var/cache/zoneminder">
    Options -Indexes +FollowSymLinks
    AllowOverride None
    <IfModule mod_authz_core.c>
        # Apache 2.4
        Require all granted
    </IfModule>
</Directory>

Alias /zm /usr/share/zoneminder/www
<Directory /usr/share/zoneminder/www>
  Options -Indexes +FollowSymLinks
  <IfModule mod_dir.c>
    DirectoryIndex index.php
  </IfModule>
</Directory>

# For better visibility, the following directives have been migrated from the
# default .htaccess files included with the CakePHP project.
# Parameters not set here are inherited from the parent directive above.
<Directory "/usr/share/zoneminder/www/api">
   RewriteEngine on
   RewriteRule ^$ app/webroot/ [L]
   RewriteRule (.*) app/webroot/$1 [L]
   RewriteBase /zm/api
</Directory>

<Directory "/usr/share/zoneminder/www/api/app">
   RewriteEngine on
   RewriteRule ^$ webroot/ [L]
   RewriteRule (.*) webroot/$1 [L]
   RewriteBase /zm/api
</Directory>

<Directory "/usr/share/zoneminder/www/api/app/webroot">
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
    RewriteBase /zm/api
</Directory>
EOF
adduser www-data video
systemctl enable --now zoneminder
a2enconf zoneminder
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod cgi
service apache2 reload
}
Debian11_Install() {
apt update
apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 gpgv -y
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
curl https://raw.githubusercontent.com/justaCasualCoder/Zoneminder-Termux/main/installzm.sh | bash
}
Alpine_Install() {
cat > /etc/apk/repositories << EOF
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community
EOF
apk update
apk add apache2 php82-apache2 mariadb mysql-client  php82-fpm php82-pdo php82-pdo_mysql  zoneminder 
# apk add php8-pdo php8-pdo_mysql mariadb mysql-client
# apk add zoneminder
service mariadb setup
service mariadb start
cat << EOF | mariadb
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
# apk add php81-fpm php81-pdo php81-pdo_mysql
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
pacman -Sy
if ! id -u temp >/dev/null 2>&1; then
    useradd -g users temp
    PASS=$(date | md5sum | cut -c1-8)
    # read -p "Remember! Temp Pass is $PASS"
    echo temp:${PASS} | chpasswd
#    echo "temp ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo "temp ALL=(ALL:ALL) NOPASSWD: /bin/yay, /bin/pacman" >> /etc/sudoers
    mkdir /home/temp/
    chown -R temp:users /home/temp
fi
pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo "Yay Is already installed!"
else
pacman -S fakeroot make git base-devel --noconfirm
cd /opt || exit 1
mkdir yay
chown temp:users yay
git clone https://aur.archlinux.org/yay-bin.git yay
chown -R temp:users ./yay
cd yay ||  { echo "Failed to clone"; echo "exit 3"; }
sudo -u  temp -- /bin/makepkg -si --noconfirm
fi
pacman -S --noconfirm apache mariadb sudo php php-apache php-fpm
echo "Fixing PHP intl:"
pacman -S --noconfirm icu
sudo -E -u temp -- yay -S icu72 --noprovides --answerdiff None --answerclean None --mflags "--noconfirm"
systemctl restart httpd
# Setup MariaDB and php modules
mysql_install_db --user=mysql --basedir=/usr/ --ldata=/var/lib/mysql/
systemctl start mysqld httpd
echo "Include conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf
sed -i 's/^LoadModule mpm_event_module modules\/mod_mpm_event\.so/#&/' /etc/httpd/conf/httpd.conf
sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork\.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf/httpd.conf
sed -i '/^#LoadModule/s/$/\nLoadModule php_module modules\/libphp.so\nAddHandler php-script .php/' /etc/httpd/conf/httpd.conf
sed -i '$ a Include conf\/extra\/php_module.conf' /etc/httpd/conf/httpd.conf
systemctl restart httpd
# echo y | yay --noprovides --answerdiff None --answerclean None --mflags "--noconfirm" zoneminder
export PATH=$PATH:/usr/bin/core_perl/
# sudo -E -u temp --  yay -S zoneminder
# Install Zoneminder
sudo -E -u temp --  yay -S zoneminder --noprovides --answerdiff None --answerclean None --mflags "--noconfirm"
sed -i "7,9 {s/^/#/}" /etc/httpd/conf/extra/zoneminder.conf
# enable httpd modules
echo "Include conf/extra/zoneminder.conf" >> /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule proxy_module modules/mod_proxy.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule rewrite_module modules/mod_rewrite.so\)|\1|' /etc/httpd/conf/httpd.conf
sed -i 's|^#\(LoadModule cgid_module modules/mod_cgid.so\)|\1|' /etc/httpd/conf/httpd.conf
sudo sed -i '$ a\LoadModule cgid_module modules/mod_cgid.so' /etc/httpd/conf/httpd.conf
systemctl restart httpd
# Setup mariadb
cat << EOF | mariadb
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
systemctl enable mariadb
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
systemctl start apache2 mariadb
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
}
Fedora_Install() {
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install nano sed httpd mariadb-server php  php-common php-mysqlnd zoneminder-httpd mod_ssl -y
ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
systemctl start httpd
systemctl start mariadb
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
systemctl start httpd zoneminder mariadb
systemctl enable httpd zoneminder mariadb
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd  --add-service=http --add-service=https
zmupdate.pl -f
}
Gentoo_Install() {
emerge app-eselect/eselect-repository
eselect repository enable oubliette
emaint sync -r oubliette
emerge dev-db/mariadb
emerge --config dev-db/mariadb
echo APACHE2_MODULES="cgi" >> /etc/portage/make.conf
emerge www-servers/apache
emerge php
emerge zoneminder
rc-update add mysql default
rc-update add zoneminder default
}
echo -n "Are you sure you want to install Zoneminder? [y/n]: " ; read yn
if [ $yn = y ]; then
    case $DISTRO in
        "Debian"|"Debian Linux") [[ $(lsb_release -r | tr -d -c 0-9 )  = 12 ]] && Debian12_Install || Debian11_Install ;;
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
