## Docker Build
After cloning the git repository, one may build the Docker image using the `--target` option tohave the right image:
```
cd build
docker build --target full_xdebug --build-arg JEEDOM_VERSION=V4-stable --tag xjeedom .
```
* Available targets are: light_jeedom, light_xdebug, full_jeedom, full_xdebug
* $JEEDOM_VERSION is beta or V4-stable (default)

### Dockerfile : génération du serveur apache - PHP

Dans le fichier dockerfile, choisir la version de php adéquate, par exemple 7.3-apache (il faut préciser buster
pour la version Debian précédente, sinon c'est la version actuelle Bullseye qui est prise)
```
FROM php:7.3-apache-buster
```

Il n'y a aucune référence directe au core Jeedom dans le Dockerfile. Ce Build (du container) ne fait
que rajouter des paquets linux (apt install ...) et des extentions php (docker-php-ext-install)
à l'image Docker de base. Jeedom est copié lors du 1er lancement du container (voir script `init.sh`).

Le contenu, i.e. la racine du répertoire pour apache, sera donc dans un répertoire partagé sur l'host ./jeedom :
```
volume "$PWD/jeedom":/var/www/html
```

# Dockerfile for Jeedom as a full standalone container

The image may be available on dockerhub :
```
docker pull pifou25/jeedom:full
```

Build image if needed.
```
docker build -t jeedom:full .
```

Run the container with required environment variables:
* MYSQL_JEEDOM_PASSWD
* MYSQL_ROOT_PASSWORD
And optional with these default values:
* MYSQL_JEEDOM_DATABASE=jeedom
* MYSQL_JEEDOM_USER=jeedom
* JEEDOM_VERSION=beta

```
docker run -p 81:80 -v jeedom:/var/www/html -v mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_JEEDOM_PASSWD=jeedom \
  --name jeedom_full pifou25/jeedom:full
```

Now you may join your new jeedom server at http://localhost:81
