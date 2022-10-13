ARG XDEBUG=false
FROM php:7.3-apache-buster as base

ENV JEEDOM_BRANCH=beta
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ENV MYSQL_HOST=db

LABEL version="Jeedom with XDebug for Docker"

# Installation des paquets
# 	ccze          : couleur pour les logs
# 	wget          : téléchargement
#   libzip-dev zip: pour l'extension php zip
#   sudo          : pour les droits sudo de jeedom
#   python*       : pour certains plugins
#   mariadb-client: pour backup et restauration

RUN apt-get update && apt-get install -y \
	wget \
	ntp \
	git iproute2 \
	sudo at

# add php extension
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions\
   bcmath calendar  \
   ssh2

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom

COPY php.ini /usr/local/etc/php/conf.d/php.ini

WORKDIR /var/www/html
VOLUME  /var/www/html

# Initialisation 
ADD init.sh /root/init.sh
RUN chmod +x /root/init.sh

# First final image: with xdebug
# docker build --target xdebug -t jeedom_xdebug .
FROM base as xdebug
# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug

# RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/xdebug.ini;
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

ENTRYPOINT ["/root/init.sh"]

# Second final image: normal without xdebug
# docker build --target jeedom -t jeedom .
FROM base as jeedom
ENTRYPOINT ["/root/init.sh"]
