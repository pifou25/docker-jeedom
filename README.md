﻿<img align="right" src="https://www.jeedom.com/site/logo.png" width="100">

[![Docker Multiplatform Build ci](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml/badge.svg)](https://github.com/pifou25/docker-jeedom/actions/workflows/buildx-platform.yml)

# Jeedom - *Innovative Home Automation*
<p align="center">
<a href="https://www.jeedom.com/">Site</a>  -
<a href="https://blog.jeedom.com/">Blog</a>  -
<a href="https://community.jeedom.com/">Community</a>  -
<a href="https://market.jeedom.com/">Market</a>  -
<a href="https://doc.jeedom.com/">Doc</a>
</p>

# Docker Jeedom : choose your style

## Jeedom As A Service (JaaS)

A complete standalone `full` Docker container including every PHP packages, Apache server,
 Python, and also many daemons: MariaDB, Cron scheduler, atd, fail2ban, supervisor....

## Jeedom as simple as possible

A very `light` container with the minimal PHP extensions over the PHP-Apache base.
No other daemon nor database, this single container should work with others services.
The `docker-compose.yml` is an example of the complete service stack used for a 
complete installation.

## Jeedom Plugins

No plugin is installed by default, because no Jeedom market account is set after the install.
You may have your own backup to initialize the installation, including all your plugins, history
and, thus, you will have to trigger any plugin dependency during the first container run.

 ## List of Docker available images

### Meaning of any keywords

* `Full`
* `Light`
* Jeedom Version `stable` (current = v4.3 = latest) or `beta` (future v4.4), see jeedom Git branches.
* `xdebug` when the image also contains XDebug packages for PHP debug

### List of generated Tags

* full-stable full latest
* full-beta beta
* debug-full-stable debug-full debug
* debug-full-beta debug-beta
* light-stable light
* light-beta 
* debug-light-stable debug-light
* debug-light-beta

# Pull and Run Jeedom As A Service

You can run the standalone `latest` container as-it :
```
docker run --name jeedom -d -v "$PWD/jeedom/":/var/www/html pifou25/jeedom
```

( --name = the container name, -d = detached mode, -v = mount the volume source:destination)

## Docker Compose for Debug and specific services

The `docker-compose.yml` is an example to run several services (mariaDB, scheduler, ...) and the `light`
Jeedom container. the `.env` file is mandatory (copy and edit the `.env.default` one).
You may edit the yml to build your own Jeedom container with these parameters:
```
  jeedom:
    # build your own image first with build-args and target:
    build:
      context: ./build
      target: light_xdebug # add target if required
      args:
        JEEDOM_VERSION: V4-stable
```
... or let the default jeedom:light-xdebug version.

Then, launch the complete service stack :
```
docker compose up -d
```
