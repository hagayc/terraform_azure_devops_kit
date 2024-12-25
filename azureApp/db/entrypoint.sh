#!/bin/bash
#SA_PASSWORD='YourStrong@Passw0rd'
# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait until SQL Server is ready
echo "Waiting for SQL Server to start..."
RETRIES=30
until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -Q "SELECT 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "SQL Server is starting up, waiting..."
  sleep 2
  RETRIES=$((RETRIES-1))
done

if [ $RETRIES -eq 0 ]; then
  echo "SQL Server did not start in expected time."
  exit 1
fi

# Run the initialization script
echo "Running initialization script..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i init.sql

# Keep container running
wait

