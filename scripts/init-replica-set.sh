#!/bin/bash
echo "Initialization of the MongoDB Replica Set ..."

# La commande mongosh pour initialiser le replica set
mongosh --eval "
rs.initiate({
    _id : 'rs0',
    members: [
        { _id : 0, host : 'mongodb_primary:27017', priority: 3},
        { _id : 1, host : 'mongodb_secondary1:27017', priority: 2 },
        { _id : 2, host : 'mongodb_secondary2:27017', priority: 1 }
    ]
});
"
echo "Replica Set initializes."