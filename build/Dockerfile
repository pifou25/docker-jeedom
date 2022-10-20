FROM php:7.3-apache-buster as base

ARG JEEDOM_VERSION=V4-stable
ENV JEEDOM_VERSION=${JEEDOM_VERSION}
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD

LABEL com.jeedom.version="Jeedom v4.x (${JEEDOM_VERSION}) for Debian Buster + PHP7.3"

# common packages intall
# alphabetical order for better compare
RUN apt-get update && apt-get install -y \
  software-properties-common && add-apt-repository non-free && \
  apt-get update && apt-get install -y \
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
  python python-pip python3 python-dev python3-pip python-virtualenv \
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

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom

WORKDIR /var/www/html
VOLUME  /var/www/html

HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
 CMD curl -s --fail http://localhost/here.html || exit 1

# First final image: with xdebug
# docker build --target xdebug -t jeedom_xdebug .
FROM base as light_xdebug
ENV MYSQL_HOST=db
# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# Initialisation 
COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh
ENTRYPOINT ["/root/init.sh"]


# Second final image: normal without xdebug
# docker build --target light_jeedom -t light_jeedom .
FROM base as light_jeedom
ENV MYSQL_HOST=db
COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh
ENTRYPOINT ["/root/init.sh"]


# third final image: full standalone
# docker build --target full_jeedom -t jeedom .
FROM base as full_jeedom
ENV MYSQL_HOST=localhost
ENV WEBSERVER_HOME=/var/www/html

RUN apt-get update && apt-get install -y \
  cron \
  fail2ban \
  mariadb-common mariadb-server \
  supervisor

# customization from official jeedom/core repo
ADD  standalone/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
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
    echo "vm.swappiness = 10" >>  /etc/sysctl.conf && \
    rm /etc/fail2ban/jail.d/defaults-debian.conf && \
    mkdir /var/run/fail2ban && \
    chown -R www-data:www-data /var/log/apache2 && \
    mkdir -p /run/mysqld && \
    chown -R www-data:www-data /run/mysqld/ && \
    chown -R www-data /etc/apache2 && \
    mkdir -p /var/run/mysqld

# Initialisation 
COPY standalone/init.sh /root/init.sh
RUN chmod +x /root/init.sh

# ENTRYPOINT ["/root/init.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


# Fourth final image: full standalone with xdebug
# docker build --target full_xdebug -t jeedom_xdebug .
FROM full_jeedom as full_xdebug
ENV MYSQL_HOST=localhost
# install xdebug
RUN pecl install redis-5.3.4 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# same CMD as full_jeedom
