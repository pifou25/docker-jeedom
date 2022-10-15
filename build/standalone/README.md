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
* JEEDOM_BRANCH=beta

```
docker run -p 81:80 -v jeedom:/var/www/html -v mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_JEEDOM_PASSWD=jeedom \
  --name jeedom_full pifou25/jeedom:full
```

Now you may join your new jeedom server at http://localhost:81
