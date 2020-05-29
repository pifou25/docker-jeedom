# php7.3 + apache + debian 10 buster jeedom
FROM php:7.3-apache

LABEL version="jeedom v4-buster"

# Installation des paquets
# 	ccze : couleur pour les logs
# 	wget : téléchargement
#   libzip-dev zip: pour l'extension php zip
#   sudo : pour les droits sudo de jeedom

RUN apt-get update && apt-get install -y \
	apt-utils \
	wget \
	ntp \
	locales \
	ccze \
	cron \
	python3 \
	libzip-dev zip \
	sudo && \
# add php extension
    docker-php-ext-install pdo pdo_mysql zip && \
# add the jeedom cron task
	echo "* * * * *  /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null" > /etc/cron.d/jeedom && \
# add sudo for www-data
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers && \
# Reduce image size
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Initialisation 
# ADD install/OS_specific/Docker/init.sh /root/init.sh
# RUN chmod +x /root/init.sh
# CMD ["sh", "/root/init.sh"]
