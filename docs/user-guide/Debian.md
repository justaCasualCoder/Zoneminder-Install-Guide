# Debian Linux

This should work for Debian 11/12

1. Update & install  Apache , PHP , and MariaDB
  ```bash
  apt update
  apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 gpgv -y
  ```

1. Set up MariaDB database
  ```bash
  cat << EOF | mysql
  BEGIN;
  CREATE DATABASE zm;
  CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
  GRANT ALL ON zm.* TO zmuser@localhost;
  FLUSH PRIVILEGES;
  EOF
  ```
3. Install Zoneminder & create MariaDB ZM database
  ```bash
  echo 'deb http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list
  apt update && apt -t bullseye-backports install zoneminder -y
  mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
  chgrp -c www-data /etc/zm/zm.conf
  ```

4. Enable Apache modules
  ```bash
  a2enconf zoneminder
  adduser www-data video
  a2enconf zoneminder
  a2enmod rewrite
  a2enmod headers
  a2enmod expires
  a2enmod cgi
  ```

5. Start & Enable everything
  ```bash
  systemctl start apache2 zoneminder mariadb
  systemctl enable apache2 zoneminder mariadb
  ```