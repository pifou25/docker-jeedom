#!/bin/sh

# this script generate SQL init using some environment variables
cat << EOF > /tmp/vaultwarden.sql
-- same user name and database name 
-- vaultwarden init sql script for MariaDB
-- https://github.com/dani-garcia/vaultwarden/wiki/Using-the-MariaDB-%28MySQL%29-Backend
CREATE DATABASE \`${MYSQL_VAULT_USER}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${MYSQL_VAULT_USER}'@'%' IDENTIFIED BY '${MYSQL_VAULT_PASSWORD}';
GRANT ALL ON \`${MYSQL_VAULT_USER}\`.* TO '${MYSQL_VAULT_USER}'@'%';
EOF

mysql -u root -p${MARIADB_ROOT_PASSWORD} < /tmp/vaultwarden.sql
