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
docker compose exec -T db healthcheck.sh --su-mysql --connect --innodb_initialized || {
    echo "Healthcheck failed after 5 retries."
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
        gunzip -c "${SQL_GZ_FILENAME}" | docker exec -i mariadb-db-1 mariadb -uroot && \
          rm "${SQL_GZ_FILENAME}"
    else
        echo "No ${db}*.sql.gz file found in ./data/"
    fi
done
