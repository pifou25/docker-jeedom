# see tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/
FROM python:3.7-buster

WORKDIR /usr/src/app

RUN pip install --no-cache-dir certbot certbot-dns-ovh

# copy the auth file .ovhapi
COPY . .

VOLUME /etc/letsencrypt

# changer ces valeurs au run
ENV DOMAIN_NAME buzut.fr
ENV EMAIL mon@email.fr

# CMD certbot certonly --dns-ovh --dns-ovh-credentials $PWD/.ovhapi -d $DOMAIN_NAME -d *.$DOMAIN_NAME
# si vous souhaitez scripter la génération
# il faut préciser à la commande de ne pas être interactive
CMD certbot certonly --dns-ovh --dns-ovh-credentials .ovhapi --non-interactive --agree-tos --email $EMAIL -d $DOMAIN_NAME -d *.$DOMAIN_NAME

# build and run:
# docker build -t certbot .
# docker run -it --rm -v /etc/letsencrypt:/etc/letsencrypt --env DOMAIN_NAME=buzut.fr --env EMAIL=mon@email.fr certbot
