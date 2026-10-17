#!/bin/bash

# check that the backup file exists
if [ -z "${1}" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

FILE=$1

if [ ! -f "${FILE}" ]; then
    echo "File ${FILE} does not exist."
    exit 1
fi

# wait with docker compose db healthy command
for i in $(seq 1 10); do
  [ "$(docker inspect --format='{{.State.Health.Status}}' $(docker compose ps -q db))" = "healthy" ] && break
  sleep 5
done
[ "$(docker inspect --format='{{.State.Health.Status}}' $(docker compose ps -q db))" = "healthy" ] || {
  echo "Healthcheck failed after 50s."
  exit 1
}


# get every env configuration: usernames and passwords
source .env

echo "untar backup ${FILE}"
tar -xf ${FILE} || \
    { echo "Error extracting ${FILE}."; exit 1; }

# restore databases in a loop
for db in npm jeedom vaultwarden yourls lychee beudeumeuh; do
    SQL_GZ_FILENAME=$(find ./data -maxdepth 1 -name "${db}*.sql.gz")
    if [ -n "${SQL_GZ_FILENAME}" ]; then
        echo "Restoring database: ${db} ${SQL_GZ_FILENAME}"
        gunzip -c "${SQL_GZ_FILENAME}" | docker compose exec -T db mariadb -uroot -p${MARIADB_ROOT_PASSWORD} && \
        rm "${SQL_GZ_FILENAME}"
    else
        echo "No ${db}*.sql.gz file found in ./data/"
    fi
done
