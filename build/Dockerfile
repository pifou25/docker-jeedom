ARG DEBIAN=bullseye
FROM php:7.3-apache-${DEBIAN} as base
ARG DEBIAN

# GitHub use this label to connect Git repo and Docker images in ghcr.io
LABEL org.opencontainers.image.source https://github.com/pifou25/docker-jeedom
LABEL org.opencontainers.artifact.description "Jeedom Home Automation in Docker"
LABEL org.opencontainers.image.authors pifou25


ARG JEEDOM_VERSION=V4-stable
ENV JEEDOM_VERSION=${JEEDOM_VERSION}
ENV WEBSERVER_HOME=/var/www/html
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

LABEL com.jeedom.version="Jeedom ${JEEDOM_VERSION} for Debian ${DEBIAN} + PHP7.3"

# common packages intall
# alphabetical order for better compare
RUN apt-get update && \
  apt-get install --no-install-recommends --no-install-suggests -q -y software-properties-common && \
  add-apt-repository non-free && \
  apt-get update && \
  apt-get install --no-install-recommends --no-install-suggests -q -y \
  apt-transport-https \
  apt-utils \
  at   # daemon atd \
  ccze # for logs colors \
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
  zip


# add php extension
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions\
   bcmath calendar imap intl ldap \
    mbstring mysqli pcntl pdo_mysql \
    soap sockets xmlrpc zip gd opcache ssh2


# install composer for dependancies
# COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
# RUN composer install

#add motd & bashrc - link sh to bash for Docker Desktop
COPY motd /etc/jmotd
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/bashrc /root/.bashrc
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd && cat /etc/jmotd' \
    >> /etc/bash.bashrc && \
    ln -sf /bin/bash /bin/sh && \
    # add sudo for www-data
	mkdir -p /etc/sudoers.d && \
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers

ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/install.sh /root/install.sh
RUN chmod +x /root/install.sh


# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom

WORKDIR ${WEBSERVER_HOME}
VOLUME ${WEBSERVER_HOME}
VOLUME ${WEBSERVER_HOME}/backup
VOLUME ${WEBSERVER_HOME}/log

# First final image: light with xdebug
FROM base as light_xdebug
ENV MYSQL_HOST=db
# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# Healthcheck for the 'light' image, apache is running ?
HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
  CMD curl -s --fail http://localhost/here.html || exit 1
# Initialisation 
COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh
ENTRYPOINT ["/root/init.sh"]


# Second final image: light without xdebug
FROM base as light_jeedom
ENV MYSQL_HOST=db
# Healthcheck for the 'light' image, apache is running ?
HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
  CMD curl -s --fail http://localhost/here.html || exit 1
COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh
ENTRYPOINT ["/root/init.sh"]


# third final image: full standalone
FROM base as full_jeedom
# localhost didn't work for mysql
ENV MYSQL_HOST=localhost 
# Add the supervisord healthcheck script
COPY standalone/healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/healthcheck.sh
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN mkdir -p '/var/run/mysqld' && \
    chown root:mysql '/var/run/mysqld' && \
    chmod 774 '/var/run/mysqld'

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -q -y \
  cron \
  fail2ban \
  # add git again because it was removed (?)
  git \
  mariadb-common mariadb-server \
  supervisor \
  && rm -rf /var/lib/apt/lists/*

# customization from official jeedom/core repo
ADD  standalone/supervisord.conf /etc/supervisor/supervisord.conf
ADD  standalone/jeedom_my.cnf /etc/mysql/conf.d/jeedom_my.cnf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_security /etc/apache2/conf-available/security.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_remoteip /etc/apache2/conf-available/remoteip.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/apache_default /etc/apache2/sites-available/000-default.conf
ADD  https://raw.githubusercontent.com/jeedom/core/${JEEDOM_VERSION}/install/fail2ban.jeedom.conf /etc/fail2ban/jail.d/jeedom.conf
ADD  php.ini /usr/local/etc/php/php.ini

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
    chown -R www-data:www-data /var/log/apache2/error.log

# Initialisation 
COPY standalone/init.sh /root/init.sh
RUN chmod +x /root/init.sh

#volume for mariadb data
VOLUME  /var/lib/mysql

# ENTRYPOINT ["/root/init.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]


# Fourth final image: full standalone with xdebug
FROM full_jeedom as full_xdebug
# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# same CMD as full_jeedom
