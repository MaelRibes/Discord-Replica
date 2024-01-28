#!/bin/bash

docker-compose up -d

echo "Waiting for MongoDB to be ready..."
while ! docker exec mongodb_primary mongosh --host mongodb_primary:27017 --eval "db.stats()" &>/dev/null; do
    sleep 5
    echo "Waiting for MongoDB..."
done

echo "MongoDB is ready. Initializing the replica set."
docker exec mongodb_primary /scripts/init-replica-set.sh