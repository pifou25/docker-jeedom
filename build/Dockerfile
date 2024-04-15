ARG DEBIAN=bullseye
ARG PHP=7.3

# prepare PHP source with dependencies
FROM composer:2.7 as vendor

ARG JEEDOM_VERSION=V4-stable
ENV JEEDOM_VERSION=${JEEDOM_VERSION}

WORKDIR /app
# Download and extract PHP sources
ADD https://github.com/jeedom/core/archive/${JEEDOM_VERSION}.zip /tmp/jeedom.zip
RUN unzip -q /tmp/jeedom.zip -d /root/ && \
  cp -R /root/core-*/* /app && \
  cp -R /root/core-*/.[!.]* /app && \
  rm -rf /root/core-* > /dev/null 2>&1 && \
  rm /tmp/jeedom.zip && \
  rm -rf /app/vendor /app/install/.htaccess
COPY install.htaccess ./install/.htaccess

# run composer for dependancies
RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist


# Build with 3 stages, 2 targets :
# first stage 'base' is common to 2 following targets
# 'light_jeedom': no daemon, only apache+php
# 'full_jeedom': standalone with all required daemons
#
# Debian version: buster / bullseye / bookworm
ARG DEBIAN=bullseye
# PHP version required for bookworm is 8 minimum
ARG PHP=7.3
FROM php:${PHP}-apache-${DEBIAN} as base
ARG DEBIAN
ARG PHP=7.3
# optional XDEBUG arg to add xdebug packages and configuration
ARG XDEBUG

# GitHub use this label to connect Git repo and Docker images in ghcr.io
LABEL org.opencontainers.image.source https://github.com/pifou25/docker-jeedom
LABEL org.opencontainers.artifact.description "Jeedom Home Automation in Docker"
LABEL org.opencontainers.image.authors pifou25

ARG JEEDOM_VERSION=V4-stable
ENV JEEDOM_VERSION=${JEEDOM_VERSION}
ARG WEBSERVER_HOME=/var/www/html
ENV WEBSERVER_HOME=${WEBSERVER_HOME}
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

LABEL com.jeedom.version="Jeedom ${JEEDOM_VERSION} for Debian ${DEBIAN} + PHP ${PHP}"

# add motd & bashrc - link sh to bash for Docker Desktop
# add sudo for www-data
COPY motd /etc/jmotd
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/bashrc /root/.bashrc
# Use bash as the default shell - replace     ln -sf /bin/bash /bin/sh && \
SHELL ["/bin/bash", "-c"]
# shellcheck disable=SC2016
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd && cat /etc/jmotd' \
    >> /etc/bash.bashrc && \
	mkdir -p /etc/sudoers.d && \
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers

# common packages intall
# alphabetical order for better compare
RUN apt-get update && \
  apt-get install --no-install-recommends --no-install-suggests -q -y software-properties-common && \
  add-apt-repository non-free && \
  apt-get update && \
  apt-get install --no-install-recommends --no-install-suggests -q -y \
  apt-transport-https \
  apt-utils \
  at \
  ccze \
  curl \
  dos2unix \
  ffmpeg \
  gettext \
  git \
  iproute2 \
  librsync-dev \
  libssh2-1 \
  libssh2-1-dev \
  libzip-dev \
  locales \
  net-tools \
  nmap \
  ntp \
  ntpdate \
  mariadb-client \
  python3 python3-dev python3-pip python3-virtualenv \
  smbclient \
  software-properties-common \
  ssl-cert \
  sudo \
  wget \
  zip unzip

# add php extension
# shellcheck disable=DL3022
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions\
   bcmath calendar imap intl ldap \
    mbstring mysqli pcntl pdo_mysql \
    soap sockets xmlrpc zip gd opcache ssh2

# change doc root apache configuration
RUN sed -ri -e "s!/var/www/html!${WEBSERVER_HOME}!g" /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!${WEBSERVER_HOME}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR ${WEBSERVER_HOME}
VOLUME ${WEBSERVER_HOME}
# copy PHP sources from previous stage
COPY --from=vendor app/ ${WEBSERVER_HOME}

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom

VOLUME ${WEBSERVER_HOME}/backup
VOLUME ${WEBSERVER_HOME}/log

# install xdebug
COPY xdebug.ini /tmp/xdebug.ini
RUN if [[ -N "$XDEBUG" ]] ; then \
  echo "XDebug Build" && \
  pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug \
  && mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini ; \
  fi

# First final image: light Jeedom with /without xdebug
FROM base as light_jeedom
ENV MYSQL_HOST=db

# Healthcheck for the 'light' image, just check if apache is running
HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
  CMD curl -s --fail http://localhost/here.html || exit 1
COPY --chmod=0775 init.sh /root/init.sh
CMD ["/root/init.sh"]


# Second final image: full standalone
FROM base as full_jeedom
# localhost didn't work for mysql, should try 127.0.0.1
ENV MYSQL_HOST=localhost

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN mkdir -p '/var/run/mysqld' && \
    chown root:mysql '/var/run/mysqld' && \
    chmod 774 '/var/run/mysqld'

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -q -y \
  cron \
  fail2ban \
  mariadb-common mariadb-server \
  supervisor \
  && rm -rf /var/lib/apt/lists/*

# customization from official jeedom/core repo
COPY  standalone/supervisord.conf /etc/supervisor/supervisord.conf
COPY  standalone/jeedom_my.cnf /etc/mysql/conf.d/jeedom_my.cnf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_security /etc/apache2/conf-available/security.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_remoteip /etc/apache2/conf-available/remoteip.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_default /etc/apache2/sites-available/000-default.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/fail2ban.jeedom.conf /etc/fail2ban/jail.d/jeedom.conf
COPY  php.ini /usr/local/etc/php/php.ini

RUN sed -i -e "s%WEBSERVER_HOME%${WEBSERVER_HOME}%g" /etc/apache2/conf-available/security.conf && \
    sed -i -e "s%WEBSERVER_HOME%${WEBSERVER_HOME}%g" /etc/apache2/conf-available/remoteip.conf && \
    rm /etc/apache2/conf-enabled/security.conf > /dev/null 2>&1 && \
    ln -s /etc/apache2/conf-available/security.conf /etc/apache2/conf-enabled/ && \
    ln -s /etc/apache2/conf-available/remoteip.conf /etc/apache2/conf-enabled/ && \
    sed -i -e "s%WEBSERVER_HOME%${WEBSERVER_HOME}%g" /etc/apache2/sites-available/000-default.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf > /dev/null 2>&1 && \
    ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/ && \
    rm /etc/apache2/conf-available/other-vhosts-access-log.conf > /dev/null 2>&1 && \
    rm /etc/apache2/conf-enabled/other-vhosts-access-log.conf > /dev/null 2>&1 && \
    echo '' > /etc/apache2/mods-available/alias.conf && \
    rm /etc/fail2ban/jail.d/defaults-debian.conf && \
    mkdir -p /var/run/fail2ban && \
    chown -R www-data /etc/apache2 && \
    rm /var/log/apache2/error.log && touch /var/log/apache2/error.log && \
    chown -R www-data:www-data /var/log/apache2/error.log && \
    chmod 0444 /etc/mysql/conf.d/jeedom_my.cnf

# Add the supervisord healthcheck script
COPY standalone/healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/healthcheck.sh
HEALTHCHECK --interval=300s --timeout=5s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh

# Initialisation
COPY --chmod=0775 standalone/init.sh /root/init.sh

#volume for mariadb data
VOLUME  /var/lib/mysql

# env config for supervisord
ENV PYTHONUNBUFFERED=True 
ENV PYTHONIOENCODING=UTF-8

# ENTRYPOINT ["/root/init.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
