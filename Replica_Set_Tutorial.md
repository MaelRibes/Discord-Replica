# Complete Tutorial for Setting Up a MongoDB Replica Set with Docker

## Introduction

This tutorial provides a comprehensive guide to setting up a MongoDB Replica Set using Docker. A Replica Set in MongoDB is a group of mongod processes that maintain the same data set, offering fault tolerance and automatic failover.

## Prerequisites

- Basic understanding of MongoDB and Docker.
- Docker and Docker Compose installed on your system.
- Access to a command line or terminal.

## Prepare Configuration Files

1. **Create the `docker-compose.yml` File**:
   - Open your preferred text editor or IDE.
   - Create a new file named `docker-compose.yml`.
   - Add the following content, defining three MongoDB services (one primary and two secondaries):

```yaml
version: '3.8'
services:
  mongo_primary:
    image: mongo
    command: mongod --replSet rs0 --port 27017
    volumes:
      - mongo_primary_data:/data/db
    networks:
      - mongo_cluster

  mongo_secondary1:
    image: mongo
    command: mongod --replSet rs0 --port 27017
    volumes:
      - mongo_secondary1_data:/data/db
    networks:
      - mongo_cluster

  mongo_secondary2:
    image: mongo
    command: mongod --replSet rs0 --port 27017
    volumes:
      - mongo_secondary2_data:/data/db
    networks:
      - mongo_cluster

networks:
  mongo_cluster:
    driver: bridge

volumes:
  mongo_primary_data:
  mongo_secondary1_data:
  mongo_secondary2_data:
```

**Note**: The `command` option in each service specifies MongoDB to start as a member of a replica set named `rs0`. The `volumes` and `networks` ensure data persistence and inter-container communication.

## Start the Containers

2. **Start the Docker Environment**:
   - Open your terminal or command prompt.
   - Navigate to the directory containing your `docker-compose.yml` file.
   - Run `docker-compose up -d`. Docker will download necessary images and start the containers.

## Initialize the Replica Set

3. **Initialize the MongoDB Replica Set**:
   - Once the containers are running, connect to the primary container with `docker exec -it mongo_primary bash`.
   - Launch the MongoDB shell by executing `mongo`.
   - Initialize the replica set with the following command:

```javascript
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo_primary:27017" },
    { _id: 1, host: "mongo_secondary1:27017" },
    { _id: 2, host: "mongo_secondary2:27017" }
  ]
});
```

**Note**: This command sets up the replica set with one primary and two secondary nodes. The `rs.initiate()` command configures and initiates the replica set.

## Verify and Test

4. **Check the Status of the Replica Set**:
   - In the MongoDB shell, execute `rs.status()` to check the state of the replica set.
   - You should see one member as `PRIMARY` and two members as `SECONDARY`.

## Connect from the Application

5. **Connect Your Application to the Replica Set**:
   - Update the MongoDB connection string in your application to include all three replica set members and specify the replica set name. For example:

```javascript
const uri = "mongodb://mongo_primary:27017,mongo_secondary1:27017,mongo_secondary2:27017/yourdbname?replicaSet=rs0";
```

**Note**: This connection string ensures that your application communicates with the replica set, utilizing the benefits of high availability and failover.

## Conclusion

By following these steps, you've successfully set up a functional MongoDB Replica Set with Docker. This setup provides high availability and automatic failover in case of node failure.

---

