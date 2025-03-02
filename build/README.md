## Docker Build

After cloning the git repository, one may build the desired Docker image using the `--target` option to have the right image
 and the `--build-arg` for the Git Branch i.e. the Jeedom version (master or beta)
```
cd build
docker build --target full_xdebug --build-arg JEEDOM_VERSION=master --tag jeedom:debug .
```
* Available targets are: light_jeedom, full_jeedom
* $DEBIAN is buster, bullseye or bookworm
* for bookworm: add $PHP with minimal version 8. $PHP=7.3 is the default value for previous Debian versions
* $XDEBUG = true / false
* $JEEDOM_VERSION is beta or master (default) (or master for the unsupported Jeedom v3)

## Github Workflow

The current workflow build all 4 targets (Jeedom Standalone, with XDebug, Jeedom Light, Light + XDebug) but only for the V4-Stable version (default build-arg).
There is another build for the same with build-arg = beta.

Supported architectures are: linux/amd64,linux/arm64,linux/arm/v7

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

Run the container with required environment variables:
* MYSQL_JEEDOM_PASSWD
* MYSQL_ROOT_PASSWORD
And optional with these default values:
* MYSQL_JEEDOM_DATABASE=jeedom
* MYSQL_JEEDOM_USER=jeedom
* JEEDOM_VERSION=beta

```
docker run -p 81:80 -v $PWD/jeedom:/var/www/html -v $PWD/mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_JEEDOM_PASSWD=jeedom \
  --hostname jeedom \
  --name jeedom jeedom:full
```

Now you may join your new jeedom server at http://localhost:81
