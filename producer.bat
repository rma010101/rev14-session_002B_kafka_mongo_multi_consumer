@echo off
echo Starting Kafka Producer...
echo.
echo This will send order messages to the Kafka topic 'my-order-updates2'
echo Make sure Kafka server and consumers are running first!
echo.
node producer.js
echo.
echo Producer finished. Press any key to close this window.
pause
