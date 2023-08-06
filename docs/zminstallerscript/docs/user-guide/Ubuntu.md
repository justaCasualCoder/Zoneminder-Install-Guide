# Ubuntu Linux

This should work on Ubuntu 20/21/22/23

1. Update & install  Apache , PHP , and MariaDB


        apt update
        apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 gpgv -y


2. Set up MariaDB database

        cat << EOF | mysql
        BEGIN;
        CREATE DATABASE zm;
        CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
        GRANT ALL ON zm.* TO zmuser@localhost;
        FLUSH PRIVILEGES;
        EOF


3. Install Zoneminder & create MariaDB ZM database


        add-apt-repository universe
        apt update 
        apt install zoneminder -y
        mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
        chgrp -c www-data /etc/zm/zm.conf

4. Enable Apache modules


        a2enconf zoneminder
        adduser www-data video
        a2enconf zoneminder
        a2enmod rewrite
        a2enmod headers
        a2enmod expires
        a2enmod cgi

5. Start & Enable everything


        systemctl start apache2 zoneminder mariadb
        systemctl enable apache2 zoneminder mariadb
