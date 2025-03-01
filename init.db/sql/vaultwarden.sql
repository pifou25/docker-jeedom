-- same user name and database name 
-- vaultwarden init sql script for MariaDB
-- https://github.com/dani-garcia/vaultwarden/wiki/Using-the-MariaDB-%28MySQL%29-Backend
CREATE DATABASE `vaultwarden` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'vaultwarden'@'%' IDENTIFIED BY 'vaultwarden';
GRANT ALL ON `vaultwarden`.* TO 'vaultwarden'@'%';

# mysql -u root -padmin < /tmp/npm.sql
