# prepare PHP source with dependencies
FROM php:8.2-cli-bookworm

RUN apt-get update && \
   apt-get install --no-install-recommends --no-install-suggests -q -y zip
WORKDIR /app

# download & run composer for dependancies
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
