# Debian Linux

This should work for Debian 12

1. Update & install  Apache , PHP , and MariaDB
  ```bash
  apt update
  apt install apache2 mariadb-server php libapache2-mod-php php-mysql lsb-release gnupg2 -y
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
  apt install zoneminder -y
  mariadb -u zmuser -pzmpass < /usr/share/zoneminder/db/zm_create.sql
  chgrp -c www-data /etc/zm/zm.conf
  chmod 640 /etc/zm/zm.conf
  ```
4. Set up Apache2 Conf
  ```bash
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
  ```
5. Enable Apache modules
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