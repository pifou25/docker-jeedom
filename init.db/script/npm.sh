#!/bin/sh

# this script generate SQL init using some environment variables
cat << EOF > /docker-entrypoint-initdb.d/npm.sql
-- same user name and database name 
FLUSH PRIVILEGES;
CREATE USER IF NOT EXISTS '${MYSQL_NPM_USER}'@'%' IDENTIFIED BY '${MYSQL_NPM_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_NPM_USER}\`;
GRANT ALL PRIVILEGES ON \`${MYSQL_NPM_USER}\`.* TO '${MYSQL_NPM_USER}'@'%';
-- GRANT ALL PRIVILEGES ON \`${MYSQL_NPM_USER}\`.* TO '${MYSQL_NPM_USER}'@'localhost';
EOF

# mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/npm.sql
