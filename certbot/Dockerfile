# see tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/
FROM python:3.7-buster

WORKDIR /usr/src/app

RUN pip install --no-cache-dir certbot certbot-dns-ovh

# copy the auth file .ovhapi
COPY . .

VOLUME /etc/letsencrypt

# changer cette valeur au run
ENV DOMAIN_NAME buzut.fr

CMD certbot certonly --dns-ovh --dns-ovh-credentials $PWD/.ovhapi -d $DOMAIN_NAME -d *.$DOMAIN_NAME

# build and run:
# docker build -t certbot .
# docker run -it --rm -v /etc/letsencrypt:/etc/letsencrypt -e DOMAIN_NAME=buzut.fr certbot
