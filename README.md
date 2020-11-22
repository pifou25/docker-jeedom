# docker-jeedom
Docker config pour Jeedom !

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

## Docker file: génération de l'image php-apache pour jeedom

### Step 1: download jeedom depuis la source github

le 1er build est mis en cache

### Step 2: génération du serveur apache - PHP

Dans le fichier dockerfile, choisir la version de php adéquate, par exemple 7.3
```
FROM php3.7-apache
```

Il n'y a aucune référence directe à l'image de jeedom dans le dockerfile. Ce fichier ne fait
que rajouter des paquets linux (apt install ...) et des extentions php (docker-php-ext-install)
à l'image docker de base. Il faut avoir au préalable téléchargé jeedom dans le répertoire 
courrant avant de démarrer le build & run de docker, par exemple avec git:

```
git clone https://github.com/jeedom/core.git -b V4-stable jeedom
```

Le contenu, i.e. la racine du répertoire pour apache, sera donc dans le sous répertoire ./jeedom :
```
volume "$PWD/core":/var/www/html
```

vous pouvez donc simplement démarrer un container jeedom avec cette commande:
```
docker build -t jeedom_img .
docker run --name jeedom -d --link mariadb:db -v "$PWD/jeedom/":/var/www/html jeedom_img
```

(build pour générer l'image, run pour démarrer le container:
 --name = le nom du container créé, -d = mode détaché, -v = volume source:destination, 
le dernier paramètre est le nom de l'image)

### add jeedom cron:
ceci est généré par le dockerfile
```
echo "* * * * *  /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null" > /etc/cron.d/jeedom
```

### add sudo for www-data
ceci est généré par le dockerfile
```
echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-mysudoers
```

## Docker compose

Le fichier docker-compose.yml utilise le dockerfile courant, et ajoute un second container pour 
la base de données - si vous ne l'avez pas déjà installée.
```
link mariadb:db
```
