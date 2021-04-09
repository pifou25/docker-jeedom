# see tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/
FROM python:3.7-buster

RUN pip3 install --no-cache-dir certbot certbot-dns-ovh

WORKDIR /app
COPY .ovhapi .ovhapi

VOLUME /etc/letsencrypt
VOLUME /var/log/letsencrypt

# first run should create certificates with all certbot parameters, python syntax :
# certbot certonly --dns-ovh --dns-ovh-credentials .ovhapi -n --agree-tos -m em@il -d domain.com
# default command is just for renew certificats
CMD ["certbot", "renew"]

# build and run, full docker syntax:
# docker build -t certbot .
# docker run -it --name certbot -v ${PWD}/letsencrypt:/etc/letsencrypt -v ${PWD)/log:/var/log/letsencrypt certbot certbot certonly --dns-ovh --dns-ovh-credentials .ovhapi --non-interactive --agree-tos --email mon@email.fr -d port.nico.si
