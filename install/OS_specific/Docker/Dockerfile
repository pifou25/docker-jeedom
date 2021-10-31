# download jeedom source from github
FROM alpine

RUN apk update && apk add --no-cache git

WORKDIR /app
VOLUME /app

# version jeedom: master ou release=v3, V4-stable, beta
# choix du download direct
CMD wget https://github.com/jeedom/core/archive/beta.zip -O /tmp/jeedom.zip && \
    unzip -q /tmp/jeedom.zip -d /root/ && \
    cp -R /root/core-*/* /app && \
    cp -R /root/core-*/.[^.]* /app && \
    rm -rf /root/core-* > /dev/null 2>&1 && \
    rm /tmp/jeedom.zip && \
    # for beta: remove anoying .htaccess
    rm /app/install/.htaccess && \
    # for beta: remove deny to the install directory
    sed -i -r '/install/d' /app/.htaccess
