#!/bin/bash

# Ensure script fails on any error
set -e

echo "Starting build process..."

# Generate SSL certificates
echo "Generating certificates..."
cd certs
./generate_certs.sh
cd ..

# Copy certificates to required locations
echo "Copying certificates to service directories..."
mkdir -p frontend/certs
mkdir -p api/certs
cp certs/certificate.crt frontend/certs/
cp certs/private.key frontend/certs/
cp certs/certificate.crt api/certs/
cp certs/private.key api/certs/

# Build and start the containers
echo "Building and starting Docker containers..."
docker-compose build --no-cache
docker-compose up 

# echo "Build process completed!"
# echo "You can access the application at:"
# echo "Frontend: https://localhost:443"
# echo "API: https://localhost:8443"