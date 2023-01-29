[![Docker Multiplatform Build ci](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml/badge.svg)](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml)

# Docker Jeedom : Un container Docker pour Jeedom !

Le container contient les `packages` nécessaires (le serveur apache + php,
 les extensions PHP, le language Python et ses extensions, le demon atd) ...

**Dans sa version "full"** (standalone) il contient égalemnet tous les demons nécessaires:
le serveur MariaDB pour la base de données, le cron, fail2ban, le supervisor.

 Le container ne contient pas Jeedom (le code) qui est cloné depuis le dépôt officiel au premier
 lancement du container. De fait, le container ne contient pas non plus les éventuels plugins qui seront
 installés ultérieurement. Ni leurs dépendances, qui sont à (re)installer à chaque mise à jour
 de l'image Docker de Jeedom.

 ## Les Tags disponibles

### Signification des tags utilisés

* `Full` : une version standalone avec tous les démons (contient le serveur de base de données, le service de cron, fail2ban, supervisord...) 
* `Light` : cette version n'est pas `standalone`, mais nécessite d'autres containers: une base de données, un service de cron (plus d'autres facultatifs, voir docker-compose.yml dans la branche nginx)
* Version de Jeedom `stable` (current = v4.3) ou `beta` (future v4.4)
* Version normale ou avec `xdebug` (pour debuggage php)

### Liste des Tags générés

* full-stable full latest
* full-beta beta
* debug-full-stable debug-full debug
* debug-full-beta debug-beta

### Jeedom Branches et Versions
* V4-stable = v4.2.x
* beta = v4.3.x
* alpha = dernière version dev en cours 
* master = release = stable = v3.x

Il faut utiliser le nom de la branche pour avoir la version cible. *Pas de build de l'ancienne v3.*

vous pouvez donc simplement démarrer un container jeedom avec cette commande:
```
docker run --name jeedom -d -v "$PWD/jeedom/":/var/www/html pifou25/jeedom
```

( --name = le nom du container créé, -d = mode détaché, -v = volume source:destination, 
le dernier paramètre est le nom de l'image)

## Initialisation
Au premier lancement du container, un script d'initialisation (init.sh) fait les différents
paramétrages en fonction des variables d'environnement définies. Puis il démarre `supervisor`
qui est le superviseur de tous les démons.

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
