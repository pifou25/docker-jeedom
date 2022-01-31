FROM php:7.3-apache-buster

LABEL version="jeedom with xdebug for development"

# Installation des paquets
# 	ccze          : couleur pour les logs
# 	wget          : téléchargement
#   libzip-dev zip: pour l'extension php zip
#   sudo          : pour les droits sudo de jeedom
#   python*       : pour certains plugins
#   mariadb-client: pour backup et restauration

RUN apt-get update && apt-get install -y \
	apt-utils \
	net-tools \
	wget \
	ntp \
	locales \
	ccze \
	python python-pip python3 python-dev python3-pip python-virtualenv \
	libzip-dev zip \
	git \
	mariadb-client \
	gettext librsync-dev \
	sudo && \
# add php extension
    docker-php-ext-install pdo pdo_mysql zip && \
# add the jeedom cron task
#	echo "* * * * *  /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null\n" > /etc/cron.d/jeedom && \
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

# install composer for dependancies
# COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
# RUN composer install

#add motd
COPY motd /etc/jmotd
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd && cat /etc/jmotd' \
    >> /etc/bash.bashrc

# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug

# COPY php.ini /usr/local/etc/php/php.ini
RUN echo "[xdebug]\n \
xdebug.client_host=host.docker.internal\n \
xdebug.discover_client_host=true\n \
xdebug.start_with_request=yes\n \
xdebug.mode=develop,coverage,debug\n \
xdebug.log=/var/www/html/log/xdebug\n \
xdebug.log_level=7\n \
xdebug.scream=1 # disable @ for php silent notice\n \
xdebug.show_error_trace=1 # always show errors\n \
xdebug.show_exception_trace=1\n \
xdebug.start_upon_error=1\n \
xdebug.client_port=9003\n" > /usr/local/etc/php/conf.d/xdebug.ini;
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/xdebug.ini;
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

WORKDIR /var/www/html
VOLUME  /var/www/html

# Initialisation 
# ADD install/OS_specific/Docker/init.sh /root/init.sh
# RUN chmod +x /root/init.sh
# CMD ["sh", "/root/init.sh"]
