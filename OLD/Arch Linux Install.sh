#!/bin/bash
pacman -S figlet --noconfirm
figlet "Made by @justacasualcoder"
sudo pacman -S nano --noconfirm
sudo pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo "Yay Is already installed!"
else
adduser temp
su -u temp <<EOF
sudo pacman -Syu
sudo pacman -S git --noconfirm
sudo pacman -S fakeroot --noconfirm
sudo pacman -S make --noconfirm
cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
EOF
fi
pacman -S apache --noconfirm
systemctl enable httpd
systemctl start httpd
pacman -S mariadb mariadb-clients libmariadbclient --noconfirm
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl start mysqld.service
systemctl enable mysqld.service
mysql_secure_installation
pacman -Syu php php-apache --noconfirm
mkdir /var/log/php
chown http /var/log/php
systemctl restart httpd.service
sed -i '66 a LoadModule php7_module modules/libphp7.so' /etc/httpd/conf/httpd.conf
sed -i '66 a AddHandler php7-script php' /etc/httpd/conf/httpd.conf
sed -i '497 a Include conf/extra/php7_module.conf' /etc/httpd/conf/httpd.conf
sed -i '409 a AddType application/x-httpd-php .php' /etc/httpd/conf/httpd.conf
sed -i '410 a AddType application/x-httpd-php-source .phps' /etc/httpd/conf/httpd.conf
replace "LoadModule mpm_event_module modules/mod_mpm_event.so" "#LoadModule mpm_event_module modulesLoadModule cgi_module modules/mod_cgi.so/mod_mpm_event.so" -- /etc/httpd/conf/httpd.conf
sed -i '66 a LoadModule mpm_prefork_module modules/mod_mpm_prefork.so' /etc/httpd/conf/httpd.conf
systemctl restart httpd
yay -S zoneminder
replace "#LoadModule proxy_module modules/mod_proxy.so" "LoadModule proxy_module modules/mod_proxy.so" -- /etc/httpd/conf/httpd.conf
replace "#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" -- /etc/httpd/conf/httpd.conf
replace "#LoadModule rewrite_module modules/mod_rewrite.so" "LoadModule rewrite_module modules/mod_rewrite.so" -- /etc/httpd/conf/httpd.conf
replace "#LoadModule cgid_module modules/mod_cgid.so" "LoadModule cgid_module modules/mod_cgid.so" -- /etc/httpd/conf/httpd.conf
replace "#LoadModule cgi_module modules/mod_cgi.so" "LoadModule cgi_module modules/mod_cgi.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=pdo_mysql.so" "extension=pdo_mysql.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=gd.so" "extension=gd.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=gettext.so" "extension=gettext.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=mcrypt.so" "extension=mcrypt.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=sockets.so" "extension=sockets.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=openssl.so" "extension=openssl.so" -- /etc/httpd/conf/httpd.conf
replace ";extension=ftp.so" "extension=ftp.so" -- /etc/httpd/conf/httpd.conf
echo "Include conf/extra/zoneminder.conf" >> /etc/httpd/conf/httpd.conf
echo 'Include conf/extra/php_module.conf' >> /etc/httpd/conf/httpd.conf
echo "open_basedir = /srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/dev/:/etc:/srv/http/zoneminder:/srv/zoneminder/:/var/cache/zoneminder/" >> /etc/php/php.ini
echo "date.timezone = America/Chicago" >> /etc/php/php.ini
cd /usr
mysql_install_db --user=mysql --ldata=/var/lib/mysql/
systemctl enable mysqld
systemctl start mysqld
mysqladmin --defaults-file=/etc/mysql/my.cnf -p -f reload
cat /usr/share/zoneminder/db/zm_create.sql | mysql --defaults-file=/etc/mysql/my.cnf -p
mysqladmin --defaults-file=/etc/mysql/my.cnf -p -f reload
cat /usr/share/zoneminder/db/zm_create.sql | mysql --defaults-file=/etc/mysql/my.cnf -p
echo 'grant lock tables, alter,select,insert,update,delete on zm.* to 'zmuser'@localhost identified by "zmpass";' | mysql --defaults-file=/etc/mysql/my.cnf -p mysql
systemctl restart httpd.service
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql 2> /dev/null
mysql -u root -p < /usr/share/zoneminder/db/zm_create.sql
mysql -u root -p -e "grant select,insert,update,delete,create,drop,alter,index,lock tables,alter routine,create routine,trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
systemd-tmpfiles --create
zmupdate.pl -f
echo " If the above command did not succesfully execute , please type in the following;                                                                              
sudo -s
zmupdate.pl -f
exit"
systemctl start zoneminder
systemctl enable zoneminder
echo " The Installation Is Done!!! :)"
