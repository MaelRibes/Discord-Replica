# Discord Replica

NICOLAS Thomas, RIBES Maël, SIMONET Théo

This project was completed as a group effort. The objective was to create a chat application that mimics the functionality of Discord. This means a user can join multiple servers, each containing several topic-centered channels that serve as chat rooms. It is also possible to add users as friends for private communication.

# Architecture

## Structure

```python
📦 Discord-Replicat
├─ 📁 Frontend
│  └─ 📁 src
│     ├─ 📁 components  # React Components
│     │  ├─ 📝 FriendView.jsx   # Friends view: list of friends + conversations
│     │  ├─ 📝 ServerList.jsx   # Server list
│     │  └─ 📝 ServerView.jsx   # Server view: channels + chat
│     ├─ 📁 pages   # Application pages
│     │  ├─ 📝 login/login.jsx  # Login page
│     │  └─ 📝 app.jsx  # Application post-login
│     └─ 📁 Styles
├─ 📁 Backend
│  ├─ 📝 backend.py  # Python API
│  ├─ 📝 db.py  # Database manipulation functions
│  ├─ 📝 models.py  # ORM models for MongoDB
│  └─ 📝 tests.py   # Database tests
└─ 📁 Stats
   └─ 📝 stats.py  # User statistics functions
```

## Technologies

![architecture](imgs_readme/architecture.PNG)

For the frontend, we use the React JS library to build our UI. React communicates with our Python Backend through API calls to fetch database information, as well as through websockets enabling real-time UI updates, such as handling new messages.

Our Python backend implements the `pydantic_mongo` library to define models corresponding to our data and use repositories to communicate with our MongoDB database. Finally, we use a second Redis database to hot-store user connections and determine if a user is presumably connected or not.

## MongoDB

Data is structured as follows:
- a `server` collection for servers.
- a `user` collection for users.

A server is a document of the form:
```javascript
{
    "id" : ... , // MongoDB server ID
    "type" : ... , // To differentiate between server and private conversation
    "name" : ... , // Server name
    "members" : [...], // List of server members
    "channels" : [...] // List of server channels
}
```
A member is an object of the form:
```javascript
{
    "user" : ... , // Corresponding user's MongoDB ID
    "role" : ...  // Admin or user
}
```
A channel is an object of the form:
```javascript
{
    "name" : ... , // Channel name
    "messages" : [...]  // List of channel messages
}
```
A message is an object of the form:
```javascript
{
    "from_user" : ... , // User's MongoDB ID
    "sent_at" : [...],  // Message date
    "content" : ... // Message content
}
```
Finally, a user is a document of the form:
```javascript
{
    "id" : ... , // User's MongoDB ID
    "login" : [...],  // User login
    "password" : ... , // Password
    "nickname" : ... , // User name
    "friends" : [...] // List of friend user IDs
}
```

With `pydantic_mongo`, we can then define models for each object/document to ensure data consistency:
```python
class Server(BaseModel):
    id: ObjectIdField = None
    type : bool
    name : str
    members : list[Member]
    channels : list[Channel] 
```

Private conversations are managed as follows:
- A private conversation is a server named username1_username2 without an administrator and with a single channel.

## Redis

To know if a user is connected or not, each user connection sets the user's name key to 1 in Redis.

To keep track of the number of connections, an entry containing the user's name is added to a Redis stream upon each connection. The key of the entry will automatically be the entry's date.
```python
r.set(username, 1) # User connected
r.xadd("connections", {'username' : username}) # Logging the connection to the connections stream
```

Upon disconnection, the user's key is deleted to indicate they are no longer connected:
```python
r.delete(socketio.server.get_session(sid).get('username')) # Removing the entry corresponding to the user
```

# ReplicaSet

A Replica Set in MongoDB is a group of MongoDB servers working together to ensure high availability and automatic recovery in case of failure. It consists of several MongoDB instances, one of which is the primary node, and the others are secondary nodes.

The primary node receives all write operations and propagates changes to the secondary nodes. The secondary nodes replicate data from the primary node and are used for read operations. If the primary node fails, one of the secondary nodes is automatically elected as the new primary node, ensuring that the system remains available.

Replica sets offer several advantages, including high availability, automatic recovery in case of failure, and scalability.

To set up our Replica Set, we execute the following commands in multiple consoles:

```shell
Console serv1
mongod --replSet rs0 --port 27018 --dbpath C:\Users\benji\data/R0S1

Console Admin:
mongosh --port 27018
rs.initiate()
rs.config()

Console serv2:
mongod --replSet rs0 --port 27019 --dbpath C:\Users\benji\data/R0S2

Console serv3:
mongod --replSet rs0 --port 27020 --dbpath C:\Users\benji\data/R0S3

Console Admin:
rs.add("localhost:27019")
rs.add("localhost:27020")


Console Arbitre:
mongod --port 30000 --dbpath C:\Users\benji\data/arb --replSet rs0


Console Admin:
db.adminCommand( { setDefaultRWConcern : 1, defaultReadConcern: {level : "majority"},defaultWriteConcern: {w : "majority"}})
rs.addArb("localhost:30000")
```

For testing purposes, the project using the replica set is located in a different branch from the main. However, the implementation in the code is relatively easy, it is enough to change the MongoDB connection line and specify that we connect to a replica set.

# Developed Features

- User connections
- Server management
- Real-time display of connected users indicated by the circle next to a user's username
- Management of rooms within a server
- Friends list
- Private conversations
- Verifications (checking login fields, can't add the same user twice to a server or as a friend, uniqueness of private conversations between two users)
- Server and user stats
- MongoDB database Replica set

# Stats

The `stats.py` file allows obtaining stats on the application from Redis, MongoDB, and pandas.
First, a diagram of the most frequently connecting users by manipulating the data from the Redis connections stream.

![Stats](imgs_readme/stats_connexions.PNG)

Then the users who send the most messages from MongoDB and an aggregates pipeline:

![Stats](imgs_readme/stats_msg.PNG)

Finally, the servers with the most messages, still with MongoDB:

![Stats](imgs_readme/stats_servers.PNG)

# Acquired Skills

- Deployment of NoSQL databases in an application
- Database replication for resilience
- Use of secondary databases for hot storage (logs, real-time connection management)
- Management of sockets between FrontEnd and BackEnd
- Aggregates pipeline for MongoDB


# Installation

Prerequisites:
- Have Docker installed

Installation:
- Open a terminal at the root of the project and run `docker-compose build` 
- Run `docker-compose up` to launch the application on `localhost:3000`

**Note**: Do not refresh the page while the application is running, or there will be socket bugs.
