# choix de la version debian:
# stretch = debian 9 (les box smart & co)
# buster = debian 10 (les DIY)
FROM php:7.3-apache-buster

LABEL version="jeedom for debian buster"

# Installation des paquets
# 	ccze          : couleur pour les logs
# 	wget          : téléchargement
#   libzip-dev zip: pour l'extension php zip
#   sudo          : pour les droits sudo de jeedom
#   python*       : pour certains plugins
#   mariadb-client: pour backup et restauration

RUN apt-get update && apt-get install -y \
	apt-utils \
	wget \
	ntp \
	locales \
	ccze \
	cron \
	python python-pip python3 python-dev python3-pip python-virtualenv \
	libzip-dev zip \
	git \
	mariadb-client \
	systemd gettext librsync-dev \
	sudo && \
# add php extension
    docker-php-ext-install pdo pdo_mysql zip && \
# add sudo for www-data
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers

# add manually duplicity v0.7.19 from jeedom image
RUN python -m pip install future fasteners && \
    wget https://images.jeedom.com/resources/duplicity/duplicity.tar.gz -O /tmp/duplicity.tar.gz && \
    tar xvf /tmp/duplicity.tar.gz -C /tmp && \
	cd /tmp/duplicity-0.7.19 && \
	python setup.py install 2>&1 >> /dev/null && \
	rm -rf /tmp/duplicity.tar.gz && \
	rm -rf duplicity-0.7.19

COPY php.ini /usr/local/etc/php/php.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# volume for jeedom core github source	
WORKDIR /var/www/html
VOLUME /var/www/html

# volume for backup
VOLUME /var/www/html/backup

# Create the log file to be able to run tail
RUN mkdir /var/www/html/log && \
    touch /var/www/html/log/cron.log

# Initialisation 
# ADD install/OS_specific/Docker/init.sh /root/init.sh
# RUN chmod +x /root/init.sh
# CMD ["sh", "/root/init.sh"]

#   prepare db config file:
#   mv /app/core/config/common.config.sample.php /app/core/config/common.config.php && \
#   sed -ri -e 's!#HOST#!db!g' /app/core/config/common.config.php  && \
#   sed -ri -e 's!#PORT#!3306!g' /app/core/config/common.config.php  && \
#   sed -ri -e 's!#DBNAME#!jeedom!g' /app/core/config/common.config.php  && \
#   sed -ri -e 's!#USERNAME#!jeedom!g' /app/core/config/common.config.php  && \
#   sed -ri -e 's!#PASSWORD#!jeedom!g' /app/core/config/common.config.php
