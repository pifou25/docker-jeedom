# get php source from another docker image
ARG PHP=8.2
ARG JEEDOM_VERSION=develop
ARG DEBIAN=bookworm
FROM ghcr.io/pifou25/jeedom:source-${PHP}-${JEEDOM_VERSION} AS source

# Base image for light jeedom: no daemon, only apache+php
#
# Debian version: bullseye / bookworm / trixie
ARG DEBIAN
# PHP version for trixie:8.4, bookworm:8.2, bullseye:7.4, buster:7.3
# base images are copied from ghcr.io/pifou25
ARG PHP
FROM php:${PHP}-apache-${DEBIAN}

ARG DEBIAN
ARG PHP
ARG TARGETPLATFORM
# optional XDEBUG arg to add xdebug packages and configuration
ARG XDEBUG=true

# repo: jeedom/core or pifou25/jeedom-core
ARG JEEDOM_REPO=pifou25/jeedom-core
# branch name: master or beta
ARG JEEDOM_VERSION
ENV JEEDOM_VERSION=${JEEDOM_VERSION}
ENV MYSQL_JEEDOM_DATABASE=jeedom
ENV MYSQL_JEEDOM_USER=jeedom
# ENV MYSQL_JEEDOM_PASSWD
# ENV MYSQL_ROOT_PASSWORD
ARG DEBIAN_FRONTEND=noninteractive
# required env var for init.sh script
ARG WEBSERVER_HOME=/var/www/html

USER root
# Use bash as the default shell - replace     ln -sf /bin/bash /bin/sh && \
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# script with common functions for installation
COPY init.sh /root/init.sh

# trixie: software-properties-common is unavaiable
RUN if [ "${DEBIAN}" != "trixie" ]; then \
      apt-get update; \
      bash -c "source /root/init.sh && apt_install software-properties-common"; \
      add-apt-repository non-free; \
    else \
      echo "Skipping software-properties-common on ${DEBIAN}" >> /tmp/build.log; \
    fi

# common packages intall
# alphabetical order for better compare
RUN apt-get update \
 && bash -c "source /root/init.sh && apt_install lsb-release build-essential tzdata apt-transport-https apt-utils at bc ccze curl dos2unix ffmpeg gettext git iproute2 \
  librsync-dev libssh2-1-dev libzip-dev locales net-tools nmap mariadb-client smbclient ssl-cert sudo wget zip unzip \
  python3 python3-dev python3-pip python3-virtualenv "

# trixie: libssh2-1 replaced by libssh2-1t64
# trixie: ntp ntpdate replaced by ntpsec
RUN bash -c "source /root/init.sh && apt_install $([ ${DEBIAN} = trixie ] && echo libssh2-1t64 ntpsec ntpsec-ntpdate || echo libssh2-1 ntp ntpdate)"

# trixie: force python3 as default python: usefull when no python2 installed
RUN if [ "${DEBIAN}" = "trixie" ]; then \
      update-alternatives --install /usr/bin/python python /usr/bin/python3 10; \
    else \
      echo "Skipping alternative python on ${DEBIAN}"; \
    fi

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
RUN bash -c "source /root/init.sh && php_install $([ ${DEBIAN} ne trixie ] && echo bcmath) \
  intl calendar ldap mbstring mysqli pcntl pdo_mysql soap sockets xmlrpc zip gd opcache ssh2" 
RUN if [ "${TARGETPLATFORM}" != "linux/arm/v6" ] && [ "${TARGETPLATFORM}" != "linux/arm/v7" ]; then \
      install-php-extensions imap; \
    else \
      echo "Skipping imap extension on ${TARGETPLATFORM}"; \
    fi

WORKDIR ${WEBSERVER_HOME}
VOLUME ${WEBSERVER_HOME}

# Download PHP sources from previous stage, and Composer
COPY --from=source /app /var/www/html
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

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

# Change uid and gid of apache to docker user uid/gid - create /tmp/jeedom
RUN usermod -u 1000 www-data \
   && groupmod -g 1000 www-data \
   && mkdir -p /tmp/jeedom \
   && chmod 777 -R /tmp/jeedom \
   && chown -R www-data:www-data -R /tmp/jeedom /root /var/www/html \
   && chmod +x /root/init.sh

# First final image: light Jeedom with /without xdebug
# the mysql hostname is another environment variable
ENV MYSQL_HOST=db

# Healthcheck for the 'light' image, just check if apache is running
HEALTHCHECK --interval=90s --timeout=3s --retries=3 --start-period=120s \
  CMD curl -s --fail http://localhost/here.html || exit 1
USER www-data
CMD ["/root/init.sh"]
