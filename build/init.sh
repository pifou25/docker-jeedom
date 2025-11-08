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
    else
      log_error "Cannot install ${pkg} - Continue anyway..."
    fi
  done
}

mysql_sql() {
  echo "$@" | mysql -uroot "-p${MYSQL_ROOT_PASSWORD}"
  if [ $? -ne 0 ]; then
    log_error "Ne peut exécuter $@ dans MySQL - Annulation"
    exit 1
  fi
}

# ==========================================================
#   Fonction principale (exécutée uniquement si appelé directement)
# ==========================================================
main() {
  log_info "starting jeedom ${JEEDOM_VERSION}"
  cd /var/www/html

  # ------------------------------------------
  #   Premier démarrage : installation
  # ------------------------------------------
  if [ ! -f "/var/www/html/index.php" ]; then
    /root/install.sh -v "${JEEDOM_VERSION}" -w /var/www/html -s 6
  fi

  if [ ! -f "/var/www/html/core/config/common.config.php" ]; then
    if [ ! -f "/var/www/html/core/config/common.config.sample.php" ]; then
      log_error "Can not install jeedom (no config.sample file)"
      exit 1
    fi

    log_info "first run of jeedom container : configuration"

    cp /var/www/html/core/config/common.config.sample.php /var/www/html/core/config/common.config.php
    sed -i "s/#PASSWORD#/${MYSQL_JEEDOM_PASSWD}/g" /var/www/html/core/config/common.config.php
    sed -i "s/#DBNAME#/${MYSQL_JEEDOM_DATABASE}/g" /var/www/html/core/config/common.config.php
    sed -i "s/#USERNAME#/${MYSQL_JEEDOM_USER}/g" /var/www/html/core/config/common.config.php
    sed -i "s/#PORT#/3306/g" /var/www/html/core/config/common.config.php
    sed -i "s/#HOST#/${MYSQL_HOST}/g" /var/www/html/core/config/common.config.php

    chmod 770 -R /var/www/html
    chown -R www-data:www-data /var/www/html
    mkdir -p /tmp/jeedom
    chmod 770 -R /tmp/jeedom
    chown www-data:www-data -R /tmp/jeedom

    # Attente du démarrage de la BDD
    while ! mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_JEEDOM_USER" -p"$MYSQL_JEEDOM_PASSWD" --silent; do
      log_warn "Wait 2 seconds for MariaDB to start..."
      sleep 2
    done

    log_info "Création de la database SQL ${MYSQL_JEEDOM_DATABASE}..."
    mysql_sql "DROP USER IF EXISTS '${MYSQL_JEEDOM_USER}'@'%';"
    mysql_sql "CREATE USER '${MYSQL_JEEDOM_USER}'@'%' IDENTIFIED BY '${MYSQL_JEEDOM_PASSWD}';"
    mysql_sql "DROP DATABASE IF EXISTS ${MYSQL_JEEDOM_DATABASE};"
    mysql_sql "CREATE DATABASE ${MYSQL_JEEDOM_DATABASE};"
    mysql_sql "GRANT ALL PRIVILEGES ON ${MYSQL_JEEDOM_DATABASE}.* TO '${MYSQL_JEEDOM_USER}'@'%';"

    log_info "jeedom clean install"
    php /var/www/html/install/install.php mode=force
    if [ $? -ne 0 ]; then
      log_error "Can not install jeedom (error in install.php, see log)"
      exit 1
    fi

    if [ -d "/var/www/html/backup" ] && [ "$(ls -A /var/www/html/backup)" ]; then
      filename=$(ls -Art /var/www/html/backup | tail -n 1)
      log_info "found a backup, try to restore: ${filename}"
      php /var/www/html/install/restore.php backup="${filename}"
    fi
    log_info " ___ successful new installation ! ___"
  fi

  # Lancer les services
  atd
  exec apache2-foreground
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
