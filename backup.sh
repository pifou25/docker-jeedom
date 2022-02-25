#!/bin/bash

FILE="data_$(date +%Y%m%d-%H%M%S).tar.gz"
echo compress /data to $FILE

# c – create an archive file.
# x – extract an archive file.
# v – show the progress of the archive file.
# f – filename of the archive file.
# z – filter archive through gzip.

# run with sudo if required
tar cvzf $FILE --exclude={"data/mosquitto/log","data/nginx/hivemq.si","data/nginx/logs","zwavetst","docker-compose"} data

# untar / restore backup:
# tar -xvf file
# or
# tar -xvf -C destination file
