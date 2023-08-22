# Alpine Linux
1. Set up repo
  ```bash
  cat > /etc/apk/repositories << EOF
  http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main
  http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community
  EOF
  apk update
  ```
    
2. Install Zoneminder , MariaDB , PHP , and Apache2 & Enable CGI
  ```bash
  apk add apache2 php81-apache2 php8-pdo php8-pdo_mysql mariadb mysql-client  php81-fpm php81-pdo php81-pdo_mysql
  apk add zoneminder
  sed -i 's/Options None/Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch/' /etc/apache2/httpd.conf
  ```

3. Set up MariaDB Databases
  ```bash
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
  ```

4. Start Everything
  ```bash
  service mariadb start
  service apache2 start
  service zoneminder start
  ```