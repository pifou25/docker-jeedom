#!/bin/sh

# ___________________________
#   constants and functions
# ___________________________
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

log_error() {
  echo "${ROUGE}$@${NORMAL}"
}

log_warn() {
  echo "${JAUNE}$@${NORMAL}"
}

log_info() {
  echo "${VERT}$@${NORMAL}"
}

log_debug() {
  echo "${BLEU}$@${NORMAL}"
}

mysql_sql() {
  # no mysql root password for standalone install
  echo "$@" | mysql -uroot # "-p${MYSQL_ROOT_PASSWORD}"
  if [ $? -ne 0 ]; then
    log_error "Ne peut exécuter $@ dans MySQL - Annulation"
    exit 1
  fi
}

# ___________________________
#   starting...
# ___________________________

log_info "starting jeedom ${JEEDOM_VERSION}"
cd /var/www/html

# ___________________________
#   first start: download sources
# ___________________________

if [ ! -f "/var/www/html/index.php" ]; then
    log_error "Can not install jeedom (no jeedom source)"
    exit 1
fi

if [ ! -f "/var/www/html/core/config/common.config.php" ]; then
  if [ ! -f "/var/www/html/core/config/common.config.sample.php" ]; then
    log_error "Can not install jeedom (no config.sample file)"
    exit 1
  fi

  # ___________________________
  #   configure database : localhost use socket configuration
  # ___________________________

  log_info "first run of jeedom container : configuration"
  cp /var/www/html/core/config/common.config.sample.php /var/www/html/core/config/common.config.php
  sed -i "s/#PASSWORD#/${MYSQL_JEEDOM_PASSWD}/g" /var/www/html/core/config/common.config.php
  sed -i "s/#DBNAME#/${MYSQL_JEEDOM_DATABASE}/g" /var/www/html/core/config/common.config.php
  sed -i "s/#USERNAME#/${MYSQL_JEEDOM_USER}/g" /var/www/html/core/config/common.config.php
  sed -i "s/#PORT#/3306/g" /var/www/html/core/config/common.config.php
  sed -i "s/#HOST#/${MYSQL_HOST}/g" /var/www/html/core/config/common.config.php
  # changes for mysql socket instead of tcp for local use
  # sed -i "s/'host'/'unix_socket'/g" ${WEBSERVER_HOME}/core/config/common.config.php
  # sed -i "s/#HOST#/\/run\/mysqld\/mysqld.sock/g" ${WEBSERVER_HOME}/core/config/common.config.php
  
  chmod 770 -R ${WEBSERVER_HOME}
  chown -R www-data:www-data ${WEBSERVER_HOME}
  mkdir -p /tmp/jeedom
  chmod 770 -R /tmp/jeedom
  chown www-data:www-data -R /tmp/jeedom

  # wait until db is up and running
  while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    log_warn "Wait 2 seconds for MariaDB to start..."
    sleep 2
  done

  log_info " ___ Création de la database SQL ${MYSQL_JEEDOM_DATABASE} pour '${MYSQL_JEEDOM_USER}'@'${MYSQL_HOST}' ... ___"
  mysql_sql "DROP DATABASE IF EXISTS ${MYSQL_JEEDOM_DATABASE};"
  mysql_sql "CREATE DATABASE ${MYSQL_JEEDOM_DATABASE};"
  mysql_sql "DROP USER IF EXISTS '${MYSQL_JEEDOM_USER}'@'*';"
  mysql_sql "CREATE USER '${MYSQL_JEEDOM_USER}'@'*' IDENTIFIED BY '${MYSQL_JEEDOM_PASSWD}';"
  mysql_sql "GRANT ALL PRIVILEGES ON ${MYSQL_JEEDOM_DATABASE}.* TO '${MYSQL_JEEDOM_USER}'@'*';"
  # user for @localhost
  mysql_sql "DROP USER IF EXISTS '${MYSQL_JEEDOM_USER}'@'localhost';"
  mysql_sql "CREATE USER '${MYSQL_JEEDOM_USER}'@'localhost' IDENTIFIED BY '${MYSQL_JEEDOM_PASSWD}';"
  mysql_sql "GRANT ALL PRIVILEGES ON ${MYSQL_JEEDOM_DATABASE}.* TO '${MYSQL_JEEDOM_USER}'@'localhost';"

  log_info "jeedom clean install"
  php /var/www/html/install/install.php mode=force
  if [ $? -ne 0 ]; then
    log_error "Can not install jeedom (error in install.php, see log)"
    exit 1
  fi

  log_warn "vérification de jeedom"
  echo "* * * * * www-data /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null" > /etc/cron.d/jeedom
  if [ $? -ne 0 ]; then
    log_error "Ne peut installer le cron de jeedom - Annulation"
    exit 1
  fi

  echo "*/5 * * * * root /usr/bin/php /var/www/html/core/php/watchdog.php >> /dev/null" > /etc/cron.d/jeedom_watchdog
  if [ $? -ne 0 ]; then
    log_error "Ne peut installer le cron de jeedom - Annulation"
    exit 1
  fi

  echo "www-data ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)
  if [ $? -ne 0 ]; then
    log_error "Ne peut permettre à jeedom d'utiliser sudo - Annulation"
    exit 1
  fi

  log_warn "vérification de jeedom"
  php /var/www/html/sick.php

  # find latest backup and try to restore at the first container launch
  if [ -d "/var/www/html/backup" ] && [ "$(ls -A /var/www/html/backup)" ]; then
     filename=$(ls -Art /var/www/html/backup)
     log_info "found a backup, try to restore: ${filename}"
     php /var/www/html/install/restore.php backup=${filename}
  fi
  log_info " ___ successfull new installation ! ___"

fi

# does NOT work inside docker container!
# sysctl vm.swappiness=10

a2dismod status
a2enmod headers
a2enmod remoteip

# required for fail2ban starting
touch /var/www/html/log/http.error
chown -R www-data:www-data /var/www/html

# start apache2 cron and fail2ban
supervisorctl start apache2
supervisorctl start cron
supervisorctl start fail2ban
