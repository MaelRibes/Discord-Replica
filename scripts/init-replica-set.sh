#!/bin/bash

mongosh --host mongodb_primary:27017 <<EOF
var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "mongodb_primary:27017",
            "priority": 3
        },
        {
            "_id": 1,
            "host": "mongodb_secondary1:27017",
            "priority": 2
        },
        {
            "_id": 2,
            "host": "mongodb_secondary2:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF
