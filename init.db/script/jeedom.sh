#!/bin/sh

# this script generate SQL init using some environment variables
cat << EOF > /docker-entrypoint-initdb.d/jeedom.sql
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
EOF

# mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/npm.sql
