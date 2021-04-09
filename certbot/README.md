# Génération certificat SSL avec certbot

C'est un script python, le container docker installe les dépendances nécessaires et lance le script.

voir le tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/

il faut avoir son nom de domaine chez OVH, utiliser un jocker (wildcard), ouvrir les accès
 à l'API OVH, générer un fichier `.ovhapi` dans ce répertoire avec les tocken de ces accès.

# Docker-Compose

Dans le répertoire /certbot: valoriser la variable DOMAIN puis lancer docker-compose dans la même ligne:

```
DOMAIN=my.domaine.com docker-compose up
```

Dans une stack existante, lancer ce service périodiquement pour renouveler les certificats enregistrés dans le répertoire /letsencrypt

# Docker
## build
```
docker build -t certbot .
```

## run
```
docker run --name certbot -v /etc/letsencrypt:/etc/letsencrypt -v "$PWD/certbot":/app -e DOMAIN_NAME=buzut.fr pifou25/certbot
```

## renew
Renouveler le bail: utilise la même image, surcharge la commande: *docker run image commande...*
```
# ce script trouve parfaitement sa place dans /usr/local/sbin/renewCerts.sh
#!/bin/bash

docker run certbot certbot certonly --dns-ovh --dns-ovh-credentials /root/.ovhapi --non-interactive --agree-tos --email mon@email.fr -d buzut.fr
docker run certbot certbot certonly --dns-ovh --dns-ovh-credentials /root/.ovhapi --non-interactive --agree-tos --email mon@email.fr -d *.buzut.fr
```
