# Génération certificat SSL avec certbot

C'est un script python, le container docker installe les dépendances nécessaires et lance le script.

voir le tuto https://buzut.net/certbot-challenge-dns-ovh-wildcard/

il faut avoir son nom de domaine chez OVH, utiliser un jocker (wildcard), ouvrir les accès
 à l'API OVH, générer un fichier `.ovhapi` dans ce répertoire avec les tocken de ces accès.
 
## build
```
docker build -t certbot --build-arg DOMAIN_NAME=buzut.fr --build-arg EMAIL=mon@email.fr .
```

## run
```
docker run -it --rm -v /etc/letsencrypt:/etc/letsencrypt certbot
```
