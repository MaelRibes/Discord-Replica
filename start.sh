#!/bin/bash

docker-compose up -d

docker exec mongodb_primary /scripts/init-replica-set.sh