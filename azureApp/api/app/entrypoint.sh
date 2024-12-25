#!/bin/bash
export DB_CONNECTION="Server=$DB_SERVICE_SERVICE_HOST,1433;$DB_CONNECTION_STATIC"
echo "Starting application with DB_CONNECTION=$DB_CONNECTION"
python main.py
