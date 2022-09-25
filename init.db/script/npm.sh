#!/bin/sh

# this script generate SQL init using some environment variables
cat << EOF > /docker-entrypoint-initdb.d/npm.sql
-- same user name and database name (and pwd ?)
FLUSH PRIVILEGES;
CREATE USER IF NOT EXISTS '${NPM_NAME}'@'%' IDENTIFIED BY '${NPM_PWD}';
CREATE DATABASE IF NOT EXISTS \`${NPM_NAME}\`;
GRANT ALL PRIVILEGES ON \`${NPM_NAME}\`.* TO '${NPM_NAME}'@'%';
-- GRANT ALL PRIVILEGES ON \`${NPM_NAME}\`.* TO '${NPM_NAME}'@'localhost';
EOF

# mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/npm.sql
