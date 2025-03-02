<img align="right" src="https://www.jeedom.com/site/logo.png" width="100">

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

## Jeedom As A Service (full)

A complete standalone `full` Docker container including every PHP packages, Apache server,
 Python, and also many daemons: MariaDB, Cron scheduler, atd, fail2ban, supervisor....

## Jeedom as simple as possible (light)

A very `light` container with the minimal PHP extensions over the PHP-Apache base.
No other daemon nor database, this single container should work with others services.
The `docker-compose.yml` is an example of the complete service stack used for a 
complete installation.

 ## List of Docker available images

### Meaning of any keywords

* `Full` = standalone
* `Light` = without extra daemon
* bullseye, buster, or bookworm is the Debian base version. The current default is `bullseye`
* Jeedom Version `stable` (current = v4.3 = latest) or `beta` (future v4.4), see jeedom Git branches.
* `debug` when the image also contains XDebug packages for PHP debug

### List of generated Tags

* full-stable full latest
* full-beta beta
* debug-full-stable debug-full debug
* debug-full-beta debug-beta
* light-stable light
* light-beta 
* debug-light-stable debug-light
* debug-light-beta

## Jeedom Plugins

No plugin is installed by default, because no Jeedom market account is set after the install.
You may have your own backup to initialize the installation, including all your plugins, history
and, thus, you will have to trigger any plugin dependency during the first container run.

# Pull and Run Jeedom As A Service

You can run the standalone `latest` container as-it :
```
docker run --name jeedom -d -v "$PWD/jeedom/":/var/www/html pifou25/jeedom
```
( --name = the container name, -d = detached mode, -v = mount the volume source:destination)

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
      target: light_jeedom # add target if required
      args:
        JEEDOM_VERSION: master
        XDEBUG: true
```
... or let the default jeedom:light version.

Then, launch the complete service stack :
```
docker compose up -d
```
