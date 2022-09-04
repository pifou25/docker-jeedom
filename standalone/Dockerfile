FROM php:7.3-apache-buster

LABEL com.jeedom.version="Jeedom v4.2 for Debian Buster + PHP7.3"

ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ENV MYSQL_HOST=localhost
ENV JEEDOM_BRANCH=beta
ENV WEBSERVER_HOME=/var/www/html

RUN apt-get update && apt-get install -y \
  software-properties-common && \
  add-apt-repository non-free && \
  apt-get update && \
  apt-get install -y \
    ntp ca-certificates unzip libzip-dev zip \
    curl sudo cron locate tar telnet iproute2 \
    wget logrotate fail2ban dos2unix ntpdate htop iotop vim iftop smbclient \
    git python python-pip python3 python3-pip \
    libexpat1 ssl-cert apt-transport-https xvfb cutycapt xauth \
    at mariadb-client mariadb-common mariadb-server \
    libsox-fmt-mp3 sox libttspico-utils supervisor \
    espeak nmap ffmpeg usbutils && \
  apt-get -y remove brltty net-tools librsync-dev

# add php extension
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions\
   bcmath calendar imap intl ldap \
    mbstring mysqli pcntl pdo_mysql \
    soap sockets xmlrpc zip gd opcache ssh2

RUN mkdir -p /var/log/supervisor

# customization
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY jeedom_my.cnf /etc/mysql/conf.d/jeedom_my.cnf
COPY apache_security /etc/apache2/conf-available/security.conf
COPY apache_remoteip /etc/apache2/conf-available/remoteip.conf
COPY apache_default /etc/apache2/sites-available/000-default.conf
COPY fail2ban.jeedom.conf /etc/fail2ban/jail.d/jeedom.conf
COPY php.ini /usr/local/etc/php/php.ini

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
    echo "vm.swappiness = 10" >>  /etc/sysctl.conf

# add manually duplicity v0.7.19 from jeedom image
# RUN python -m pip install future fasteners && \
#    wget https://images.jeedom.com/resources/duplicity/duplicity.tar.gz -O /tmp/duplicity.tar.gz && \
#    tar xvf /tmp/duplicity.tar.gz -C /tmp && \
# cd /tmp/duplicity-0.7.19 && \
# python setup.py install 2>&1 >> /dev/null && \
# rm -rf /tmp/duplicity.tar.gz && \
# rm -rf duplicity-0.7.19

# install composer for dependancies
# COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
# RUN composer install

#add motd - link sh to bash for Docker Desktop
COPY motd /etc/jmotd
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd && cat /etc/jmotd' \
    >> /etc/bash.bashrc && \
	ln -sf /bin/bash /bin/sh

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom \
   && usermod -a -G dialout,tty www-data

WORKDIR /var/www/html
VOLUME  /var/www/html
VOLUME /var/lib/mysql

# Initialisation 
COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh

# ENTRYPOINT ["/root/init.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]