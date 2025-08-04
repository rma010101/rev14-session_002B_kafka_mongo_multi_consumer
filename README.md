# Kafka + MongoDB + Redis Multi-Consumer Node.js Example

This project demonstrates how to use Apache Kafka with Node.js, MongoDB, and Redis for a multi-consumer order processing scenario with caching optimization.

## Node.js Dependencies & Installation

This project requires the following Node.js packages:

- `kafka-node` – Kafka client for Node.js
- `mongodb` – MongoDB client for Node.js
- `redis` – Redis client for Node.js

If you do not have a `package.json` file, first initialize your project:

```
npm init -y
```

Then install all dependencies:

```
npm install kafka-node mongodb redis
```

Or simply:
```
npm install
```
if you already have a `package.json` file with the dependencies listed.

## Prerequisites
- Java (for Kafka and ZooKeeper)
- Node.js and npm
- MongoDB running on `localhost:27017`
- Redis running on default port `6379`
- Kafka and ZooKeeper (downloaded and extracted, e.g., `C:\kafka\kafka_2.13-3.9.1`)

## Setup Steps

### 1. Start ZooKeeper
Open a terminal and run:
```
C:\kafka\kafka_2.13-3.9.1\bin\windows\zookeeper-server-start.bat C:\kafka\kafka_2.13-3.9.1\config\zookeeper.properties
```

### 2. Start Kafka Broker
Open a new terminal and run:
```
C:\kafka\kafka_2.13-3.9.1\bin\windows\kafka-server-start.bat C:\kafka\kafka_2.13-3.9.1\config\server.properties
```

### 3. Create Kafka Topic
```
C:\kafka\kafka_2.13-3.9.1\bin\windows\kafka-topics.bat --create --topic my-order-updates2 --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

> **Note:** The topic name `my-order-updates2` must be exactly the same as the topic used in your `producer.js` and `consumer.js` files.

#### Example: Where to Set the Topic Name

**In `producer.js`:**
```js
function sendOrderMessage(order) {
    const orderMessage = JSON.stringify(order);
    producer.send([{ topic: 'my-order-updates2', messages: orderMessage, partition: 0 }], (err, data) => {
        // ...
    });
}
```

**In `consumer.js`:**
```js
const consumer = new kafka.Consumer(kafkaClient, [{ topic: 'my-order-updates2', partition: 0 }], { autoCommit: true });
```

### 4. Start MongoDB
Ensure MongoDB is running on the default port `27017`. The consumer will connect to the `ecommerce` database and use the `products` collection.

### 5. Start Redis
Ensure Redis is running on the default port `6379` for caching functionality.

### 6. Run the Consumer
```
node consumer.js
```

### 7. Run the Producer
```
node producer.js
```

## Files
- `producer.js`: Sends order messages to Kafka topic with order details (orderId, productId, quantity).
- `consumer.js`: Listens for order messages, updates product stock in MongoDB, and uses Redis for caching product data.
- `package.json`: Node.js dependencies and project configuration.

## Key Features

### Multi-Consumer Architecture
- **Producer**: Sends order messages to Kafka topic
- **Consumer**: Processes orders and updates stock levels
- **MongoDB Integration**: Stores product data in `ecommerce.products` collection
- **Redis Caching**: Improves performance by caching frequently accessed product data

### Cache Strategy
- **Cache Hit**: Product data retrieved from Redis
- **Cache Miss**: Data fetched from MongoDB and cached in Redis
- **Cache Invalidation**: Redis cache cleared after stock updates

### Data Flow
1. Producer sends order message to Kafka
2. Consumer receives message and extracts productId and quantity
3. Consumer checks Redis cache for product data
4. If cache miss, fetches from MongoDB
5. Updates product stock in MongoDB
6. Invalidates Redis cache for updated product

## Monitoring & Logs

### Application Logs
- **Consumer logs**: Displayed in the terminal where you run `node consumer.js`
- **Producer logs**: Displayed in the terminal where you run `node producer.js`

### Kafka Logs
- **Kafka Server logs**: `C:\kafka\kafka_2.13-3.9.1\logs\server.log`
- **Kafka data logs**: `C:\kafka\kafka_2.13-3.9.1\kafka-logs\` (topic partitions and metadata)
- **ZooKeeper logs**: `C:\kafka\kafka_2.13-3.9.1\logs\zookeeper.log`

### Monitor Kafka Topics
```bash
# List all topics
C:\kafka\kafka_2.13-3.9.1\bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092

# Monitor messages in real-time
C:\kafka\kafka_2.13-3.9.1\bin\windows\kafka-console-consumer.bat --topic my-order-updates2 --from-beginning --bootstrap-server localhost:9092

# Check consumer group status
C:\kafka\kafka_2.13-3.9.1\bin\windows\kafka-consumer-groups.bat --bootstrap-server localhost:9092 --list
```

### MongoDB Logs
- **Default location**: `C:\Program Files\MongoDB\Server\{version}\log\mongod.log`
- **Custom location**: Check your MongoDB configuration file for log path

### Redis Logs
- **Console output**: Redis logs appear in the terminal where you started `redis-server`
- **Log file**: Can be configured in `redis.conf` if using configuration file

## Learning Points
- How to set up and run Kafka and ZooKeeper on Windows
- How to produce and consume messages with `kafka-node` in Node.js
- How to integrate MongoDB for data persistence
- How to implement Redis caching for performance optimization
- How to handle cache invalidation strategies
- How to process order data and update inventory in real-time
- How to resolve common Kafka startup errors (e.g., cluster ID mismatch)
- How to monitor and debug distributed systems using logs

---
