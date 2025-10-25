# Base image for light jeedom: no daemon, only apache+php
# 'full_jeedom': standalone with all required daemons
#
# Debian version: bullseye / bookworm / trixie
ARG DEBIAN=trixie
# PHP version for trixie:8.4, bookworm:8.2, bullseye:7.4, buster:7.3
# base images are copied from ghcr.io/pifou25
ARG PHP=8.4
FROM php:${PHP}-apache-${DEBIAN}
ARG DEBIAN
ARG PHP
ARG TARGETPLATFORM
# optional XDEBUG arg to add xdebug packages and configuration
ARG XDEBUG=true

# repo: jeedom/core or pifou25/jeedom-core
ARG JEEDOM_REPO=pifou25/jeedom-core
# branch name: master or beta
ARG JEEDOM_VERSION=develop
ENV JEEDOM_VERSION=${JEEDOM_VERSION}
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ARG DEBIAN_FRONTEND=noninteractive
# required env var for init.sh script
ENV WEBSERVER_HOME=/var/www/html

USER root
# Use bash as the default shell - replace     ln -sf /bin/bash /bin/sh && \
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# common packages intall
# alphabetical order for better compare
RUN apt-get update 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y tzdata
# trixie: software-properties-common is unavaiable
RUN if [ "${DEBIAN}" != "trixie" ]; then \
      apt-get install --no-install-recommends --no-install-suggests -q -y software-properties-common; \
      add-apt-repository non-free; \
      apt-get update; \
    else \
      echo "Skipping software-properties-common on ${DEBIAN}"; \
    fi

RUN apt-get install --no-install-recommends --no-install-suggests -q -y apt-transport-https 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y apt-utils at bc ccze
RUN apt-get install --no-install-recommends --no-install-suggests -q -y curl dos2unix 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y ffmpeg gettext git 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y iproute2 
# trixie: libssh2-1 replaced by libssh2-1t64
RUN apt-get install --no-install-recommends --no-install-suggests -q -y $([ ${DEBIAN} = trixie ] && echo libssh2-1t64 || echo libssh2-1 )
RUN apt-get install --no-install-recommends --no-install-suggests -q -y librsync-dev libssh2-1-dev libzip-dev 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y locales net-tools 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y nmap
# trixie: ntp ntpdate replaced by ntpsec
RUN apt-get install --no-install-recommends --no-install-suggests -q -y $([ ${DEBIAN} = trixie ] && echo ntpsec ntpsec-ntpdate || echo ntp ntpdate)
RUN apt-get install --no-install-recommends --no-install-suggests -q -y mariadb-client 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y python3 python3-dev python3-pip python3-virtualenv 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y smbclient 
RUN apt-get install --no-install-recommends --no-install-suggests -q -y ssl-cert sudo wget
RUN apt-get install --no-install-recommends --no-install-suggests -q -y zip unzip
# trixie: force python3 as default python: usefull when no python2 installed
RUN if [ "${DEBIAN}" = "trixie" ]; then \
      update-alternatives --install /usr/bin/python python /usr/bin/python3 10; \
    else \
      echo "Skipping alternative python on ${DEBIAN}"; \
    fi
RUN 

# GitHub use this label to connect Git repo and Docker images in ghcr.io
LABEL org.opencontainers.image.source="https://github.com/pifou25/docker-jeedom"
LABEL org.opencontainers.artifact.description="Jeedom Home Automation in Docker"
LABEL org.opencontainers.image.authors="pifou25"
LABEL com.jeedom.version="${JEEDOM_REPO} ${JEEDOM_VERSION} for Debian ${DEBIAN} + PHP ${PHP}"
LABEL org.opencontainers.image.description="Jeedom Home Automation in Docker. ${JEEDOM_REPO} ${JEEDOM_VERSION} for Debian ${DEBIAN} + PHP ${PHP}"

# add motd & bashrc - link sh to bash for Docker Desktop
# add sudo for www-data
COPY motd /etc/jmotd
ADD  https://raw.githubusercontent.com/${JEEDOM_REPO}/${JEEDOM_VERSION}/install/bashrc /root/.bashrc
# shellcheck disable=SC2016
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd && cat /etc/jmotd' \
    >> /etc/bash.bashrc && \
	mkdir -p /etc/sudoers.d && \
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers

# add php extension
# shellcheck disable=DL3022
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
# RUN install-php-extensions bcmath
RUN install-php-extensions "$([ ${DEBIAN} ne trixie ] && echo bcmath)" calendar
RUN if [ "${TARGETPLATFORM}" != "linux/arm/v6" ] && [ "${TARGETPLATFORM}" != "linux/arm/v7" ]; then \
      install-php-extensions imap; \
    else \
      echo "Skipping imap extension on ${TARGETPLATFORM}"; \
    fi

RUN install-php-extensions intl
RUN install-php-extensions ldap
RUN install-php-extensions mbstring
RUN install-php-extensions mysqli
RUN install-php-extensions pcntl
RUN install-php-extensions pdo_mysql
RUN install-php-extensions soap
RUN install-php-extensions sockets
RUN install-php-extensions xmlrpc
RUN install-php-extensions zip
RUN install-php-extensions gd
RUN install-php-extensions opcache
RUN install-php-extensions ssh2

WORKDIR ${WEBSERVER_HOME}
VOLUME ${WEBSERVER_HOME}

# Download and extract PHP sources from $repo:$branch
ADD https://github.com/${JEEDOM_REPO}/archive/${JEEDOM_VERSION}.zip /tmp/jeedom.zip
RUN unzip -q /tmp/jeedom.zip -d /tmp/source/ && \
  find /tmp/source/ -maxdepth 1 -type d -name '*core*' -exec sh -c "mv -T {} ${WEBSERVER_HOME}" {} \; && \
  rm /tmp/jeedom.zip && \
  rm -rf /app/vendor /app/install/.htaccess
COPY install.htaccess ./install/.htaccess

# download & run composer for dependancies
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
# no composer update for master branch (i.e. Jeedom:4.4.x) /vendor already exists and up-to-date in git repo
RUN if [ "${JEEDOM_VERSION}" != "master" ]; then \
    composer install --no-progress --no-interaction --no-dev; \
    fi

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown www-data:www-data -R /tmp/jeedom

VOLUME ${WEBSERVER_HOME}/backup
VOLUME ${WEBSERVER_HOME}/log

# install redis-5.3.4 + xdebug-3.1.6 for php7.4 and 3.3.2 for php8.2
# install redis-6.2.0 and xdebug-3.4.5 for php8.4/trixie
# check https://xdebug.org/docs/compat
COPY xdebug.ini /tmp/xdebug.ini
RUN if [[ ${XDEBUG} == "true" ]] ; then \
  pecl install $([ ${DEBIAN} = trixie ] && echo redis-6.2.0 || echo redis-5.3.4 ) \
	&& pecl install $([ $(echo "${PHP} >= 8.0" | bc) == 1 ] && echo xdebug-3.4.5 || echo xdebug-3.1.6 ) \
	&& docker-php-ext-enable redis xdebug \
  && mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini ; \
  fi

# First final image: light Jeedom with /without xdebug
# the mysql hostname is another environment variable
ENV MYSQL_HOST=db

# Healthcheck for the 'light' image, just check if apache is running
HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
  CMD curl -s --fail http://localhost/here.html || exit 1
COPY --chmod=0775 init.sh /root/init.sh
USER www-data
CMD ["/root/init.sh"]
