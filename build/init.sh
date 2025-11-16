#!/bin/bash
set -e  # Stoppe à la première erreur non gérée

# ==========================================================
#   Couleurs (désactivées si sortie non interactive)
# ==========================================================
if [ -t 1 ]; then
  VERT="\\033[1;32m"
  NORMAL="\\033[0;39m"
  ROUGE="\\033[1;31m"
  ROSE="\\033[1;35m"
  BLEU="\\033[1;34m"
  BLANC="\\033[0;02m"
  BLANCLAIR="\\033[1;08m"
  JAUNE="\\033[1;33m"
  CYAN="\\033[1;36m"
else
  VERT=""; NORMAL=""; ROUGE=""; ROSE=""; BLEU=""
  BLANC=""; BLANCLAIR=""; JAUNE=""; CYAN=""
fi

# ==========================================================
#   Fonctions de log
# ==========================================================
log_error() { echo "${ROUGE}$@${NORMAL}"; }
log_warn()  { echo "${JAUNE}$@${NORMAL}"; }
log_info()  { echo "${VERT}$@${NORMAL}"; }
log_debug() { echo "${BLEU}$@${NORMAL}"; }

# ==========================================================
#   Fonctions utilitaires
# ==========================================================
apt_install() {
  for pkg in "$@"; do
    echo "Installing ${pkg}..."
    if apt-get --quiet --option Dpkg::Options::="--force-confdef" --yes install "$pkg" > /dev/null; then
      log_info "${pkg} installed"
      echo "${pkg} installed" >> /tmp/build.log
    else
      log_error "Cannot install ${pkg} - Continue anyway..."
      echo "Cannot install ${pkg} - Continue anyway..." >> /tmp/build.log
    fi
  done
}

php_install() {
  for pkg in "$@"; do
    echo "Installing ${pkg}..."
    if install-php-extensions "$pkg" > /dev/null; then
      log_info "PHP ${pkg} installed"
      echo "PHP ${pkg} installed" >> /tmp/build.log
    else
      log_error "Cannot install PHP ${pkg} - Continue anyway..."
      echo "Cannot install PHP ${pkg} - Continue anyway..." >> /tmp/build.log
    fi
  done
}

mysql_sql() {
  if [[ "${MYSQL_HOST}" == 'localhost' ]]; then
    # pas de password en localhost
    echo "$@" | mysql -uroot
  elif [[ -n "${MYSQL_ROOT_PASSWORD}" ]]; then
    echo "$@" | mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --host=${MYSQL_HOST} --port=${MYSQL_PORT:3306} 
  else
    echo "$@" | mysql -u"${MYSQL_JEEDOM_USER}" -p"${MYSQL_JEEDOM_PASSWD}" --host=${MYSQL_HOST} --port=${MYSQL_PORT:3306} 
  fi
  if [ $? -ne 0 ]; then
    log_error "Ne peut exécuter $@ dans MySQL (${MYSQL_HOST}:${MYSQL_PORT:3306}) - Annulation"
    exit 1
  fi
}

# ==========================================================
#   Fonction principale (exécutée uniquement si appelé directement)
# ==========================================================
main() {
  log_info "starting jeedom ${JEEDOM_VERSION}"
  cd ${WEBSERVER_HOME}

  # ------------------------------------------
  #   Premier démarrage : installation
  # ------------------------------------------
  if [ ! -f "${WEBSERVER_HOME}/index.php" ]; then
    log_error "No Jeedom installation on ${WEBSERVER_HOME} !"
    exit 1
  fi

  if [[ "${MYSQL_HOST}" != 'localhost' ]]; then
    # add en debug & tache de fond:
    atd -d -f && log_info "Démarrage du démon atd" || log_warn "Erreur démarrage atd"
  fi
  
  if [ ! -f "${WEBSERVER_HOME}/core/config/common.config.php" ]; then
    if [ ! -f "${WEBSERVER_HOME}/core/config/common.config.sample.php" ]; then
      log_error "Can not install jeedom (no config.sample file)"
      exit 1
    fi

    log_info "first run of jeedom container : configuration"

    if [[ -z "${MYSQL_JEEDOM_PASSWD}" ]]; then
      MYSQL_JEEDOM_PASSWD=$(openssl rand -base64 32 | tr -d /=+ | cut -c -15)
      log_info "Mot de passe aléatoire pour Jeedom: ${MYSQL_JEEDOM_PASSWD}"
    fi

    cp ${WEBSERVER_HOME}/core/config/common.config.sample.php ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#PASSWORD#/${MYSQL_JEEDOM_PASSWD}/g" ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#DBNAME#/${MYSQL_JEEDOM_DATABASE}/g" ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#USERNAME#/${MYSQL_JEEDOM_USER}/g" ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#PORT#/${MYSQL_PORT:3306}/g" ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#HOST#/${MYSQL_HOST}/g" ${WEBSERVER_HOME}/core/config/common.config.php

    chmod 770 -R ${WEBSERVER_HOME}
    chown -R www-data:www-data ${WEBSERVER_HOME}
    mkdir -p /tmp/jeedom
    chmod 770 -R /tmp/jeedom
    chown www-data:www-data -R /tmp/jeedom

    # wait until db is up and running
    wait_time=2
    max_wait=300  # (optionnel) temps max entre deux essais
    while ! mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_JEEDOM_USER" -p"$MYSQL_JEEDOM_PASSWD" --port=${MYSQL_PORT:3306} --silent; do
      log_warn "Wait ${wait_time}s for MariaDB to start..."
      sleep "$wait_time"
      # double le temps d’attente, mais limite à max_wait
      wait_time=$(( wait_time * 2 ))
      if [ "$wait_time" -gt "$max_wait" ]; then
        # end script with error
        log_error "No database available, check your configuration: $MYSQL_HOST"
        exit 1
      fi
    done

    if [[ "${MYSQL_HOST}" == 'localhost' ]]; then
      log_info " ___ Création de la database SQL ${MYSQL_JEEDOM_DATABASE} pour '${MYSQL_JEEDOM_USER}'@'${MYSQL_HOST}' ... ___"
      mysql_sql "DROP USER IF EXISTS '${MYSQL_JEEDOM_USER}'@'%';"
      mysql_sql "CREATE USER '${MYSQL_JEEDOM_USER}'@'%' IDENTIFIED BY '${MYSQL_JEEDOM_PASSWD}';"
      mysql_sql "DROP DATABASE IF EXISTS ${MYSQL_JEEDOM_DATABASE};"
      mysql_sql "CREATE DATABASE ${MYSQL_JEEDOM_DATABASE};"
      mysql_sql "GRANT ALL PRIVILEGES ON ${MYSQL_JEEDOM_DATABASE}.* TO '${MYSQL_JEEDOM_USER}'@'%';"
      # user for @localhost
      mysql_sql "DROP USER IF EXISTS '${MYSQL_JEEDOM_USER}'@'localhost';"
      mysql_sql "CREATE USER '${MYSQL_JEEDOM_USER}'@'localhost' IDENTIFIED BY '${MYSQL_JEEDOM_PASSWD}';"
      mysql_sql "GRANT ALL PRIVILEGES ON ${MYSQL_JEEDOM_DATABASE}.* TO '${MYSQL_JEEDOM_USER}'@'localhost';"
    else
      log_info " ___ La database SQL ${MYSQL_JEEDOM_DATABASE} pour '${MYSQL_JEEDOM_USER}'@'${MYSQL_HOST}:${MYSQL_PORT:3306}' doit être disponible..."

    fi

    log_info "jeedom clean install"
    php ${WEBSERVER_HOME}/install/install.php mode=force
    if [ $? -ne 0 ]; then
      log_error "Can not install jeedom (error in install.php, see log)"
      exit 1
    fi

    log_warn "vérification de jeedom"
    php ${WEBSERVER_HOME}/sick.php

   # find latest backup and try to restore at the first container launch
   if [ -d "${WEBSERVER_HOME}/backup" ] && [ "$(ls ${WEBSERVER_HOME}/backup/*.gz)" ]; then
      filename=$(ls -Art ${WEBSERVER_HOME}/backup | tail -n 1)
      log_info "found a backup, try to restore: ${filename}"
      php ${WEBSERVER_HOME}/install/restore.php backup="${filename}"
    fi
    log_info " ___ successful new installation ! ___"
  fi

  if [[ "${MYSQL_HOST}" == 'localhost' ]]; then
    # SI  config 'full' lancer les services via supervisord
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

  else
    # Sinon Lancer les services 'light'
    exec apache2-foreground
  fi
}

# ==========================================================
#   Exécution conditionnelle
# ==========================================================
# Si le script est exécuté directement (bash init.sh)
# alors on lance main()
# Sinon, s’il est "sourcé", on ne fait rien.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
