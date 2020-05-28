# php7.3 + apache + debian 9 stretch jeedom
FROM php:7.3-apache-stretch

LABEL version="stretch-jeedom"

# ENV SHELL_ROOT_PASSWORD password
# ENV MYSQL_ROOT_PASSWD mysql-password

# Installation des paquets
# 	ccze : couleur pour les logs
# 	wget : téléchargement
# 	openssh-server : serveur ssh

RUN apt-get update && apt-get install -y \
	apt-utils \
	wget \
	ntp \
	# openssh-server \
	locales \
	ccze \
	cron \
	python3 \
	libzip-dev zip \ # for php zip extension
	sudo \ # for jeedom sudo rights
	nano

# default port for web server
# EXPOSE 80 22 443

# html and log directory
# VOLUME /var/www/html

# Serveur SSH
# RUN mkdir /var/run/sshd
# RUN echo "root:${SHELL_ROOT_PASSWORD}" | chpasswd && \
#	sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#	sed -ri 's/^#?Port 22/Port 22/' /etc/ssh/sshd_config && \
#   sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# add php extension
RUN docker-php-ext-install pdo pdo_mysql zip
# add the jeedom cron task
RUN echo "* * * * *  /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null" > /etc/cron.d/jeedom && \
  # add sudo for www-data
  echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers
