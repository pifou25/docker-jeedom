## Docker Build

After cloning the git repository, one may build the desired Docker image using the `--target` option to have the right image
 and the `--build-arg` for the Git Branch i.e. the Jeedom version (master or beta)
```
cd build
docker build --target full_xdebug --build-arg JEEDOM_VERSION=master --tag jeedom:debug .
```

* $DEBIAN is bullseye or bookworm
* for bookworm:$PHP=8.2 ; for bullseye:$PHP=7.4
* $XDEBUG = true / false
* $JEEDOM_VERSION is beta or master (default)

## Github Workflow

The current workflow build several images, each of them for bookworm & PHP8.2 and bullseye & PHP7.4:
- master light
- master full with supervisor and all daemons
- beta light with xdebug enabled
- beta full

Supported architectures are: linux/amd64,linux/arm64,linux/arm/v7

# Dockerfile for Jeedom as a full standalone container

The image may be available on dockerhub :
```
docker pull pifou25/jeedom:latest
```

Run the container with required environment variables:
* MYSQL_JEEDOM_PASSWD
* MYSQL_ROOT_PASSWORD
And optional with these default values:
* MYSQL_JEEDOM_DATABASE=jeedom
* MYSQL_JEEDOM_USER=jeedom
* JEEDOM_VERSION=beta

```
docker run -p 80:80 -v $PWD/jeedom:/var/www/html -v $PWD/mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_JEEDOM_PASSWD=jeedom \
  --hostname jeedom \
  --name jeedom jeedom:full
```

Now you may join your new jeedom server at http://localhost:80
