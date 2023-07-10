FROM debian:11
#ARG ENV_FILE=./zm_config_docker
#ENV $(cat $ENV_FILE | grep -v ^# | xargs)
RUN apt update && apt install apache2 openssl mariadb-server php gpgv libapache2-mod-php php-mysql lsb-release gnupg2 -y
COPY openssl.cnf /etc/ssl/openssl.cnf
RUN openssl req -x509 -nodes -days 2190 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt 
RUN sed -i '/^\s*SSLRandomSeed/s/^/#/' /etc/apache2/mods-available/ssl.conf && sed -i '/<IfModule mod_ssl.c>/a\        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt'  /etc/apache2/mods-available/ssl.conf  && sed -i '/<IfModule mod_ssl.c>/a\        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key'  /etc/apache2/mods-available/ssl.conf  &&  a2ensite default-ssl
RUN a2enmod ssl
RUN service mariadb start && cat <<EOF | mariadb
BEGIN;
CREATE DATABASE zm;
CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
GRANT ALL ON zm.* TO zmuser@localhost;
FLUSH PRIVILEGES;
EOF
RUN echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list && apt update && apt -t bullseye-backports install zoneminder -y
RUN service mariadb start && mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
RUN chgrp -c www-data /etc/zm/zm.conf && adduser www-data video && a2enconf zoneminder && a2enmod rewrite && a2enmod headers && a2enmod expires && a2enmod cgi
RUN chown -R www-data:www-data /usr/share/zoneminder
RUN echo "<Directory /usr/share/zoneminder/www/api>" >> /etc/apache2/conf-available/zoneminder.conf && echo "    AllowOverride All" >> /etc/apache2/conf-available/zoneminder.conf && echo "</Directory>" >> /etc/apache2/conf-available/zoneminder.conf
RUN chown www-data:www-data /etc/apache2/conf-available/zoneminder.conf
RUN /etc/init.d/mariadb restart && /etc/init.d/zoneminder start && /etc/init.d/apache2 start
EXPOSE 80
EXPOSE 443
CMD service mariadb start && service zoneminder start && apache2ctl -D FOREGROUND