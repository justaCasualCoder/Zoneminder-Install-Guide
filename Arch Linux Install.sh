#!/bin/bash
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
sudo pacman -S nano --noconfirm
sudo pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo "Yay Is already installed!"
else
sudo pacman -Syu
sudo pacman -S git --noconfirm
sudo pacman -S fakeroot --noconfirm
sudo pacman -S make --noconfirm
cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
fi
sudo pacman -Syu apache --noconfirm
sudo systemctl enable httpd.service
sudo mkdir -p /srv/http/default
sudo mkdir -p /srv/http/example.com/public_html
sudo mkdir -p /srv/http/example.com/logs
sudo systemctl start httpd.service
sudo pacman -Syu mariadb mariadb-clients libmariadbclient --noconfirm
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service
sudo mysql_secure_installation
sudo pacman -Syu php php-apache --noconfirm
sudo mkdir /var/log/php
sudo chown http /var/log/php
sudo systemctl restart httpd.service
sudo sed -i '66 a LoadModule php7_module modules/libphp7.so' /etc/httpd/conf/httpd.conf
sudo sed -i '66 a AddHandler php7-script php' /etc/httpd/conf/httpd.conf
sudo sed -i '497 a Include conf/extra/php7_module.conf' /etc/httpd/conf/httpd.conf
sudo sed -i '409 a AddType application/x-httpd-php .php' /etc/httpd/conf/httpd.conf
sudo sed -i '410 a AddType application/x-httpd-php-source .phps' /etc/httpd/conf/httpd.conf
sudo replace "LoadModule mpm_event_module modules/mod_mpm_event.so" "#LoadModule mpm_event_module modulesLoadModule cgi_module modules/mod_cgi.so/mod_mpm_event.so" -- /etc/httpd/conf/httpd.conf
sudo sed -i '66 a LoadModule mpm_prefork_module modules/mod_mpm_prefork.so' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd.service
yay -S zoneminder
sudo replace "#LoadModule proxy_module modules/mod_proxy.so" "LoadModule proxy_module modules/mod_proxy.so" -- /etc/httpd/conf/httpd.conf
sudo replace "#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" -- /etc/httpd/conf/httpd.conf
sudo replace "#LoadModule rewrite_module modules/mod_rewrite.so" "LoadModule rewrite_module modules/mod_rewrite.so" -- /etc/httpd/conf/httpd.conf
sudo replace "#LoadModule cgid_module modules/mod_cgid.so" "LoadModule cgid_module modules/mod_cgid.so" -- /etc/httpd/conf/httpd.conf
sudo replace "#LoadModule cgi_module modules/mod_cgi.so" "LoadModule cgi_module modules/mod_cgi.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=pdo_mysql.so" "extension=pdo_mysql.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=gd.so" "extension=gd.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=gettext.so" "extension=gettext.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=mcrypt.so" "extension=mcrypt.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=sockets.so" "extension=sockets.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=openssl.so" "extension=openssl.so" -- /etc/httpd/conf/httpd.conf
sudo replace ";extension=ftp.so" "extension=ftp.so" -- /etc/httpd/conf/httpd.conf
sudo echo "Include conf/extra/zoneminder.conf" >> /etc/httpd/conf/httpd.conf
sudo echo 'Include conf/extra/php_module.conf' >> /etc/httpd/conf/httpd.conf
sudo echo "open_basedir = /srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/dev/:/etc:/srv/http/zoneminder:/srv/zoneminder/:/var/cache/zoneminder/" >> /etc/php/php.ini
sudo echo "date.timezone = America/Chicago" >> /etc/php/php.ini
cd /usr
sudo mysql_install_db --user=mysql --ldata=/var/lib/mysql/
sudo systemctl enable mysqld
sudo systemctl start mysqld
sudo mysqladmin --defaults-file=/etc/mysql/my.cnf -p -f reload
sudo cat /usr/share/zoneminder/db/zm_create.sql | mysql --defaults-file=/etc/mysql/my.cnf -p
sudo mysqladmin --defaults-file=/etc/mysql/my.cnf -p -f reload
sudo cat /usr/share/zoneminder/db/zm_create.sql | mysql --defaults-file=/etc/mysql/my.cnf -p
echo 'grant lock tables, alter,select,insert,update,delete on zm.* to 'zmuser'@localhost identified by "zmpass";' | mysql --defaults-file=/etc/mysql/my.cnf -p mysql
sudo systemctl restart httpd.service
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql 2> /dev/null
sudo mysql -u root -p < /usr/share/zoneminder/db/zm_create.sql
sudo mysql -u root -p -e "grant select,insert,update,delete,create,drop,alter,index,lock tables,alter routine,create routine,trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
sudo systemd-tmpfiles --create
zmupdate.pl -f
echo " If the above command did not succesfully execute , please type in the following; ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
sudo -s
zmupdate.pl -f
exit"
sudo systemctl start zoneminder
sudo systemctl enable zoneminder
echo " The Installation Is Done!!! :)"
