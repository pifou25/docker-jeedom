# docker-jeedom
Stack Docker All-In-One pour Jeedom !

Contient :
* Ninx Proxy Manager : Reverse-Proxy
* MariaDB
* Jeedom (version FROM apache-php)
* Scheduler : le cron
* MQTT Brocker
* ZWaveJS2MQTT
* PhpMyAdmin

# Installation

Installer docker & docker-compose. Et git.

Cloner ce repo, branche nginx:
```
git clone https://github.com/pifou25/docker-jeedom.git -b nginx
```
copier `.env.default` en `.env` et modifier les variables, en particulier _important_ les mots de passe !

Générer un fichier password pour mosquito - le brocker MQTT - avec le user & mot de passe: ils seront à renseigner dans la configuration du plugin jeedom MQTT, mais aussi dans le container ZWaveJS2Mqtt pour la connexion au brocker.
```
cd mosquito/config
docker run -ti --rm -v $PWD:/tmp eclipse-mosquitto mosquitto_passwd -c /tmp/password jeedom
```

Puis... Lancer la stack:
```
docker-compose up -d
```
