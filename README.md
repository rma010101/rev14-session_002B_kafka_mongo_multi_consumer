# Kafka MongoDB Multi-Consumer Project

## Overview
This project demonstrates a real-time order processing system using Apache Kafka for message streaming, MongoDB for data persistence, and Redis for caching. It implements a producer-consumer pattern where order messages are published to Kafka topics and consumed to update product stock in MongoDB with Redis caching for performance optimization.

## Architecture

```
Producer (producer.js) 
    ↓ (publishes order messages)
Kafka Topic (my-order-updates2)
    ↓ (consumes messages)
Consumer (consumer.js)
    ↓ (updates stock)
MongoDB (ecommerce.products) + Redis Cache
```

## Technologies Used

- **Apache Kafka**: Message streaming platform for real-time data processing
- **MongoDB**: NoSQL database for product data storage
- **Redis**: In-memory caching for performance optimization
- **Node.js**: Runtime environment
- **kafka-node**: Node.js client library for Apache Kafka

## Project Structure

```
├── producer.js          # Kafka producer for sending order messages
├── consumer.js          # Kafka consumer for processing orders and updating stock
├── package.json         # Project dependencies and scripts
├── kafkakafka_2.13-3.9.1kafka-logs/  # Kafka log files
└── kafkakafka_2.13-3.9.1zookeeper-data/  # Zookeeper data files
```

## Dependencies

```json
{
  "kafka-node": "^5.0.0",
  "mongodb": "^6.18.0",
  "redis": "^5.7.0"
}
```

## Key Learning Concepts

### 1. Kafka Producer (`producer.js`)

#### Basic Producer Setup
```javascript
const kafka = require('kafka-node');
const kafkaClient = new kafka.KafkaClient({ kafkaHost: 'localhost:9092' });
const producer = new kafka.Producer(kafkaClient);
```

#### Message Publishing
- **Topic**: `my-order-updates2`
- **Partition**: 0 (single partition setup)
- **Message Format**: JSON stringified order objects

#### Key Functions:
- `sendOrderMessage(order)`: Sends order messages to Kafka topic
- Handles producer events: `ready` and `error`

### 2. Kafka Consumer (`consumer.js`)

#### Consumer Configuration
```javascript
const consumer = new kafka.Consumer(
    kafkaClient, 
    [{ topic: 'my-order-updates2', partition: 0 }], 
    { autoCommit: true }
);
```

#### Message Processing Flow
1. **Receive**: Listen for messages from Kafka topic
2. **Parse**: Convert JSON message to JavaScript object
3. **Process**: Extract productId and quantity
4. **Update**: Modify product stock in MongoDB
5. **Cache**: Manage Redis cache for performance

### 3. MongoDB Integration

#### Database Schema
- **Database**: `ecommerce`
- **Collection**: `products`
- **Document Structure**:
  ```javascript
  {
    product_id: Number,
    stock: Number,
    // other product fields
  }
  ```

#### Operations
- **Find**: `productsCollection.findOne({ product_id: productId })`
- **Update**: `productsCollection.updateOne({ product_id: productId }, { $set: { stock: newStock } })`

### 4. Redis Caching Strategy

#### Cache Implementation
- **Cache Key Pattern**: `product_${productId}`
- **Cache Hit**: Retrieve product data from Redis
- **Cache Miss**: Fetch from MongoDB, then cache
- **Cache Invalidation**: Delete cache entry after stock update

#### Benefits
- Reduced database queries
- Improved response times
- Better system performance under load

### 5. Advanced Kafka Concepts (Commented Code)

The project includes commented examples of advanced Kafka features:

#### Multi-Partition Support
```javascript
function sendOrderMessageMultiPartition(order, partition = null) {
    // Send to specific partition or auto-distribute
}
```

#### Partitioning Strategies
1. **Specific Partition**: Manual partition assignment
2. **Auto-Partition**: Kafka round-robin distribution
3. **Hash Partitioning**: Customer ID-based partitioning
4. **Multiple Partitions**: Broadcast to multiple partitions

## Setup and Installation

### Prerequisites
1. **Apache Kafka** (with Zookeeper)
   - Download from: https://kafka.apache.org/downloads
   - Extract to a directory (e.g., `/path/to/kafka_2.13-3.9.1`)
   - Note: Replace `/path/to/kafka_2.13-3.9.1` with your actual Kafka installation path
2. **MongoDB**
3. **Redis**
4. **Node.js**

### Installation Steps

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Start Services**
   ```bash
   # Navigate to Kafka installation directory first
   cd /path/to/kafka_2.13-3.9.1
   
   # Start Zookeeper
   bin/zookeeper-server-start.sh config/zookeeper.properties
   
   # Start Kafka Server (in a new terminal, same directory)
   bin/kafka-server-start.sh config/server.properties
   
   # Start MongoDB (in a new terminal)
   mongod
   
   # Start Redis (in a new terminal)
   redis-server
   ```

3. **Create Kafka Topic**
   ```bash
   # From Kafka installation directory (/path/to/kafka_2.13-3.9.1)
   bin/kafka-topics.sh --create --topic my-order-updates2 --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
   ```

4. **Run Application**
   ```bash
   # Start Consumer (in one terminal)
   node consumer.js
   
   # Start Producer (in another terminal)
   node producer.js
   ```

## Data Flow Example

### Input (Producer)
```javascript
{ orderId: 1, productId: 101, quantity: 1 }
{ orderId: 3, productId: 101, quantity: 3 }
```

### Processing (Consumer)
1. Receive order message from Kafka
2. Check Redis cache for product data
3. If cache miss, fetch from MongoDB
4. Calculate new stock: `currentStock - orderQuantity`
5. Update MongoDB with new stock
6. Invalidate Redis cache
7. Log success/failure

### Output
```
Processing order for product 101, quantity: 1
Product stock updated for product 101, new stock: 99
```

## Error Handling

### Stock Validation
```javascript
if (newStock >= 0) {
    // Update stock
} else {
    console.log('Insufficient stock');
}
```

### Connection Error Handling
- Kafka producer/consumer error events
- MongoDB connection error handling
- Redis connection error handling

## Performance Optimizations

1. **Redis Caching**: Reduces MongoDB queries
2. **Auto-commit**: Kafka consumer automatically commits offsets
3. **Asynchronous Processing**: Non-blocking operations
4. **Connection Pooling**: Reuse database connections

## Key Learnings

### 1. Event-Driven Architecture
- Decoupled producer and consumer systems
- Asynchronous message processing
- Scalable system design

### 2. Data Consistency
- Cache invalidation strategies
- Stock validation before updates
- Transaction-like behavior for stock updates

### 3. System Integration
- Multiple technology stack integration
- Inter-service communication via Kafka
- Data persistence and caching strategies

### 4. Kafka Concepts
- Topics and partitions
- Producer-consumer pattern
- Message serialization (JSON)
- Offset management (auto-commit)

### 5. Database Patterns
- Cache-aside pattern with Redis
- Document-based storage with MongoDB
- Query optimization through caching

## Potential Enhancements

1. **Multi-Partition Setup**: Scale with multiple partitions
2. **Consumer Groups**: Multiple consumer instances
3. **Error Queues**: Dead letter queues for failed messages
4. **Monitoring**: Add logging and metrics
5. **Data Validation**: Schema validation for messages
6. **Transactions**: Implement distributed transactions
7. **Load Balancing**: Multiple consumer instances
8. **Fault Tolerance**: Retry mechanisms and circuit breakers

## Troubleshooting

### Common Issues
1. **Kafka Connection**: Ensure Kafka and Zookeeper are running
2. **Topic Not Found**: Create topic before running producer/consumer
3. **MongoDB Connection**: Verify MongoDB service is running
4. **Redis Connection**: Check Redis server status
5. **Port Conflicts**: Ensure default ports are available

### Debug Commands
```bash
# Navigate to Kafka installation directory first
cd /path/to/kafka_2.13-3.9.1

# List Kafka topics
bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Check consumer groups
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Monitor topic messages
bin/kafka-console-consumer.sh --topic my-order-updates2 --from-beginning --bootstrap-server localhost:9092
```

## Conclusion

This project demonstrates a practical implementation of modern distributed systems concepts including:
- Message streaming with Apache Kafka
- NoSQL data storage with MongoDB
- Performance optimization with Redis caching
- Event-driven architecture patterns
- Real-time data processing workflows

The combination of these technologies provides a foundation for building scalable, high-performance applications that can handle real-time data processing requirements in modern e-commerce and enterprise systems.
