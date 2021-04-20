# download jeedom source from github
FROM alpine:3.10

# version jeedom: master ou release=v3, V4-stable
RUN apk update && apk add --no-cache git

WORKDIR /app
VOLUME /app

CMD git clone https://github.com/jeedom/core.git -b master /app
