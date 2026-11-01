<img align="right" src="https://raw.githubusercontent.com/pifou25/docker-jeedom/master/img/jeedom_logo.png" width="100" height="100">

[![Docker Multiplatform Build ci](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml/badge.svg)](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/pifou25/jeedom)
![GitHub forks](https://img.shields.io/github/forks/pifou25/docker-jeedom)
[![Try in PWD](https://img.shields.io/badge/try-it_now!-blue?logo=docker&color=lemon)](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/pifou25/docker-jeedom/master/docker-compose.yml)

# Jeedom - *Innovative Home Automation*
<p align="center">
<a href="https://www.jeedom.com/">Site</a>  -
<a href="https://blog.jeedom.com/">Blog</a>  -
<a href="https://community.jeedom.com/">Community</a>  -
<a href="https://market.jeedom.com/">Market</a>  -
<a href="https://doc.jeedom.com/">Doc</a>
</p>

# Docker Jeedom : choose your style

## Jeedom AIO All-In-One (full)

A complete standalone `full` Docker container including every PHP packages, Apache server,
 Python, and also many daemons: MariaDB, Cron scheduler, atd, (fail2ban), (supervisor)....

## Jeedom as a Service Jaas (http)

A very `light` container with the minimal PHP extensions over the PHP-Apache base.
No other daemon nor database, this single container should work with others services.
The `docker-compose.yml` is an example of the complete service stack used for a 
complete installation.

## List of Docker available images

### Meaning of any keywords

* tag format: <jeedom version>-<debian name>-<?http>
* debian name: **bookworm**, or **trixie** is the **Debian** base version. The current default is `bookworm` running with php8.2 ; trixie=php8.4
* Jeedom Version / branch:
* * `master`: (current = v4.6.2 = latest stable)
* * `develop` (next v4.6.3, see develop branch with xdebug)
* * `integration`  (v5.0.0 custom branch from custom repository with xdebug) 

### List of generated Tags

* 4.6.2-bookworm 4.6
* 4.6.2-bookworm-http
* 5.0.0-bookworm
* 4.6.2-trixie-http
* 5.0.0-trixie-http
* ...

### Supported architectures:

* linux/amd64
* linux/arm64
* linux/arm/v7

## Jeedom Plugins

No plugins are installed by default, because no Jeedom market account is set after the install.
You may have your own backup to initialize the installation, including all your plugins, history
and, thus, you will have to trigger any plugin dependency during the first container run.

# Build and Run

## Build images in this order

* light http image
`docker build -t pifou25/jeedom:6.4-trixie-http-int --build-arg DEBIAN=trixie --build-arg PHP=8.4 --build-arg JEEDOM_REPO=pifou25/jeedom-core --build-arg JEEDOM_VERSION=master --build-arg XDEBUG=true  -f build/Dockerfile  build`
* full Jeedom AIO based on the previous one
`docker build -t pifou25/jeedom:6.4-trixie-int --build-arg BASENAME=6.4-trixie-http-int -f build/Dockerfile.full build`

## Pull and Run Jeedom As A Service

You can run the standalone `latest` container as-it :
```
docker run --name jeedom -d -v "$PWD/jeedom":/var/www/html -v "$PWD/mysql":/var/lib/mysql pifou25/jeedom
```
( --name = the container name, -d = detached mode, -v = mount the volume source:destination)

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
  --name jeedom pifou25/jeedom:6.4-bookworm
```

Now you may join your new jeedom server at http://localhost:80

## run a new container with an existing backup

The init sequence may track and restore a previous Jeedom backup:
```
docker run --name jeedom -d -v "$PWD/backup":/var/www/html/backup pifou25/jeedom
```

## Docker Compose for Debug and specific services

The `docker-compose.yml` is an example to run several services (mariaDB, scheduler, ...) and the `light`
Jeedom container. the `.env` file is mandatory (copy and edit the `.env.default` one).
You may edit the yml to build your own Jeedom container with these parameters:
```
  jeedom:
    # build your own image first with build-args and target:
    build:
      context: ./build
      args:
        JEEDOM_VERSION: master
        XDEBUG: true
```
... or let the default jeedom:light version.

Then, launch the complete service stack :
```
docker compose up -d
```
