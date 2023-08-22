# Fedora Linux

1. Set up repo & install MariaDB , PHP , Apache , Zoneminder & Enable Zoneminder conf
  ```bash
  dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
  dnf install nano sed httpd mariadb-server php  php-common php-mysqlnd zoneminder-httpd mod_ssl -y
  ln -sf /etc/zm/www/zoneminder.httpd.conf /etc/httpd/conf.d/
  ``` 
2. Start MariaDB & set up database
  ```bash
  systemctl start mariadb
  mysql < /usr/share/zoneminder/db/zm_create.sql
  cat << EOF | mysql
  BEGIN;
  CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';
  GRANT ALL ON zm.* TO zmuser@localhost;
  FLUSH PRIVILEGES;
  EOF
  ```
3. Start & Enable everything
  ```bash
  setenforce 0
  systemctl start httpd zoneminder mariadb
  systemctl enable httpd zoneminder mariadb
  ```

4. Set firewall open ports & Update Zoneminder database
  ```bash
  firewall-cmd --permanent --add-service=http
  firewall-cmd --permanent --add-service=https
  firewall-cmd  --add-service=http --add-service=https
  zmupdate.pl -f
  ```