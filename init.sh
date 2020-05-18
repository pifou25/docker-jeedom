#!/bin/bash

MYSQL_ROOT_PASSWD=$MYSQL_ROOT_PASSWD

log_file='/root/init.log'
exec >> $log_file 2>&1

echo 'Start init'

if [ -f /var/www/html/core/config/common.config.php ]; then
	echo 'Jeedom is already install'
else
	echo 'Start jeedom installation'
	apt-get install -y apache2 apache2-utils libexpat1 ssl-cert
	service apache2 start
	rm -rf /tmp/install.sh
	wget https://raw.githubusercontent.com/jeedom/core/V4-stable/install/install.sh -O /tmp/install.sh
	chmod +x /tmp/install.sh
	/tmp/install.sh -m $MYSQL_ROOT_PASSWD
fi

echo 'Start atd'
service atd restart

if [ $(which mysqld | wc -l) -ne 0 ]; then
	echo 'Starting mysql'
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
	service mysql restart
fi

if ! [ -f /.jeedom_backup_restore ]; then
	if [ ! -z "${RESTOREBACKUP}" ] && [ "${RESTOREBACKUP}" != 'NO' ]; then
		echo 'Need restore backup '${RESTOREBACKUP}
		wget ${RESTOREBACKUP} -O /tmp/backup.tar.gz
		php /var/www/html/install/restore.php backup=/tmp/backup.tar.gz
		rm /tmp/backup.tar.gz
		touch /.jeedom_backup_restore
		if [ ! -z "${UPDATEJEEDOM}" ] && [ "${UPDATEJEEDOM}" != 'NO' ]; then
			echo 'Need update jeedom'
			php /var/www/html/install/update.php
		fi
	fi
fi

echo 'All init complete'
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chown -R www-data:www-data /var/www/html

echo 'Start sshd'
service ssh start

echo 'Start apache2'
service apache2 start

cron -f