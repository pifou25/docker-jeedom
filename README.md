# docker-jeedom
 Docker config for Jeedom

## Creer le réseau

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

## Docker file

FROM arm32v7/php3.7-apache

add cron unzip ntp
configure pdo-mysql

### add jeedom cron:
```
echo "* * * * *  /usr/bin/php /var/www/html/core/php/jeeCron.php >> /dev/null" > /etc/cron.d/jeedom
```

## Docker compose

link mariadb:db
port 8090:80
network mymacvlan

volume "$PWD/core":/var/www/html
volume "$PWD/logsDeb9Jeedom3:/var/www/html/logs
