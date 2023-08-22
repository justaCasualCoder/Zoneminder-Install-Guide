# OpenSuSE Linux

This should work on OpenSUSE Tumbleweed

1. Set up zoneminder repo
  ```bash
  zypper addrepo https://download.opensuse.org/repositories/security:zoneminder/openSUSE_Tumbleweed/security:zoneminder.repo
  zypper --gpg-auto-import-keys refresh
  zypper -n refresh
  ```
2. Install Zoneminder
  ```bash
  zypper -n install apache2 php php-mysql php-gd php-mbstring apache2-mod_php8 mariadb mariadb-client ZoneMinder php8-intl
  ```

3. Enable Apache2 Modules
  ```bash
  a2enmod rewrite
  a2enmod headers
  a2enmod expires
  a2enmod php8
  ```
4. Set up MariaDB database
  ```bash
  cat << EOF | mariadb
  BEGIN;
  CREATE DATABASE zm;
  CREATE USER zm_admin@localhost IDENTIFIED BY 'zmpass';
  GRANT ALL ON zm.* TO zm_admin@localhost;
  FLUSH PRIVILEGES;
  EOF
  mariadb -u zm_admin -pzmpass < /usr/share/zoneminder/db/zm_create.sql
  ```
5. Set up firewall
  ```bash
  firewall-cmd --permanent --add-port=80/tcp
  firewall-cmd --permanent --add-port=443/tcp
  firewall-cmd --reload
  ```
6. Start & Enable everything
  ```bash
  systemctl start apache2 zoneminder mariadb
  systemctl enable apache2 zoneminder mariadb
  ```