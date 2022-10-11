# Docker Jeedom : Un container Docker pour Jeedom !

Le container contient les `packages` nécessaires (le serveur apache + php,
 le serveur MariaDB pour la base de données, les extensions PHP, le language Python et ses extensions) ...

 Le container ne contient pas Jeedom (le code) qui est cloné depuis le dépôt officiel au premier
 lancement du container. De fait, le container ne contient pas non plus les éventuels plugins qui seront
 installés ultérieurement.

 ## Les Tags disponibles

* Version de Jeedom `stable` (current = v4.2) ou `beta` (future v4.3)
* Version normale ou avec `xdebug` (pour debuggage php)
* `Full` (complet et autonome, contient le serveur de base de données, le service de cron...) ou `Light`.

La version `light` ne peut tourner seule, mais nécessite d'autres containers: 
une base de données, un service de cron (plus d'autres
facultatifs, voir docker-compose.yml dans la branche nginx)

* full-stable full latest
* full-beta beta
* debug-full-stable debug-full debug
* debug-full-beta debug-beta

### Dockerfile : génération du serveur apache - PHP

Dans le fichier dockerfile, choisir la version de php adéquate, par exemple 7.3-apache (il faut préciser buster
pour la version Debian précédente, sinon c'est la version actuelle Bullseye qui est prise)
```
FROM php:7.3-apache-buster
```

Il n'y a aucune référence directe au core Jeedom dans le Dockerfile. Ce Build (du container) ne fait
que rajouter des paquets linux (apt install ...) et des extentions php (docker-php-ext-install)
à l'image Docker de base. Jeedom est copié lors du 1er lancement du container.

Le contenu, i.e. la racine du répertoire pour apache, sera donc dans un répertoire partagé sur l'host ./jeedom :
```
volume "$PWD/jeedom":/var/www/html
```

vous pouvez donc simplement démarrer un container jeedom avec cette commande:
```
docker run --name jeedom -d -v "$PWD/jeedom/":/var/www/html pifou25/jeedom
```

( --name = le nom du container créé, -d = mode détaché, -v = volume source:destination, 
le dernier paramètre est le nom de l'image)

## Creer le réseau

Pour **certains plugins** il est nécessaire de configurer un réseau local 
spécifique utilisé par docker et ses containers: c'est **facultatif** pour le core jeedom
et la plupart des plugins
```
docker network create \
  -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.240/29 \
  --gateway=192.168.1.254 \
  --aux-address="host_bridge=192.168.1.241" \
  -o parent=eth0 \
  mymacvlan
```
subnet = réseau existant

gateway = IP de la box

## Docker compose

Le fichier docker-compose.yml utilise le Dockerfile courant, et ajoute un second container pour 
la base de données - si vous ne l'avez pas déjà installée.
```
link mariadb:db
```
