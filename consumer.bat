@echo off
echo Starting Kafka Consumer...
echo.
echo This consumer will listen for order messages from Kafka topic 'my-order-updates2'
echo and update MongoDB product stock with Redis caching.
echo.
echo Make sure MongoDB, Redis, and Kafka server are running first!
echo.
node consumer.js
echo.
echo Consumer stopped. Press any key to close this window.
pause
