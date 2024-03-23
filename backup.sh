#!/bin/bash

cd /home/pi/dev/nginx
# remove previous backups
rm data/*.sql.gz

# get evry env configuration: usernames and passwords
source .env

NOW=$(date +%Y%m%d-%H%M%S)
FILE="data_$NOW.tar.gz"

# database backup:
# TODO remove the clear root password and the docker container name
# backup npm:
# https://github.com/NginxProxyManager/nginx-proxy-manager/discussions/1529#discussioncomment-1921806
echo backup databases: npm jeedom yourls nextcloud

docker exec nginx-db-1 sh -c 'exec mysqldump --databases npm -uroot -p"${MYSQL_ROOT_PASSWORD}"' | gzip -c > data/npm_$NOW.sql.gz
docker exec nginx-db-1 sh -c 'exec mysqldump --databases jeedom -uroot -p"${MYSQL_ROOT_PASSWORD}"' | gzip -c > data/jeedom_$NOW.sql.gz
# docker exec nginx-db-1 sh -c 'exec mysqldump --databases yourls -uroot -p"${MYSQL_ROOT_PASSWORD}"' | gzip -c > data/yourls_$NOW.sql.gz
# docker exec nginx-db-1 sh -c 'exec mysqldump --databases nextcloud -uroot -p"${MYSQL_ROOT_PASSWORD}"' | gzip -c > data/nextcloud_$NOW.sql.gz

# restore database:
# docker exec -i some-mariadb sh -c 'exec mysql -uroot -p"${MYSQL_ROOT_PASSWORD}"' < /some/path/on/your/host/all-databases.sql

echo compress /data to $FILE
# c – create an archive file.
# x – extract an archive file.
# v – show the progress of the archive file.
# f – filename of the archive file.
# z – filter archive through gzip.

# run with sudo if required
tar czf $FILE --exclude={"data/mosquitto/log","data/nginx/hivemq.si","data/nginx/logs","zwavetst","docker-compose","*.log","*.log.gz","ib_logfile0","data/mysql"} data

# untar / restore backup:
# tar -xvf file
# or
# tar -xvf -C destination file

# send to FTP backup site
HOST='mafreebox.freebox.fr'
REMOTEPATH='/Freebox/PiBackup/jeedom'

ftp -n ${HOST} <<END_SCRIPT
quote USER ${FTP_USER}
quote PASS ${FTP_PASSWORD}
cd ${REMOTEPATH}
put ${FILE}
quit
END_SCRIPT
exit 0
