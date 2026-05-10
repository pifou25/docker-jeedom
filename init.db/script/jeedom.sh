#!/bin/sh

# this script generate SQL init using some environment variables
cat << EOF > /tmp/jeedom.sql
CREATE USER IF NOT EXISTS '${MYSQL_JEEDOM_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_JEEDOM_DB}\`;
GRANT ALL PRIVILEGES ON \`${MYSQL_JEEDOM_DB}\`.* TO '${MYSQL_JEEDOM_USER}'@'%';
EOF

# mysql -u root -p${MARIADB_ROOT_PASSWORD} < /tmp/jeedom.sql
