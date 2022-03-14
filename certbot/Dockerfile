# see tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/
FROM python:3.7-buster

RUN pip install --no-cache-dir certbot certbot-dns-ovh

WORKDIR /app

VOLUME /etc/letsencrypt
VOLUME /app

# changer cette valeur au run
ENV DOMAIN_NAME buzut.fr

CMD certbot certonly --dns-ovh --dns-ovh-credentials /app/.ovhapi -d $DOMAIN_NAME -d *.$DOMAIN_NAME

# build and run:
# docker build -t certbot .
# docker run --name certbot -v /etc/letsencrypt:/etc/letsencrypt -v "$PWD/certbot":/app -e DOMAIN_NAME=example.nico.si certbot
