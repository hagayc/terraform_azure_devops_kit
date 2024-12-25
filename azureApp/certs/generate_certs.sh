#!/bin/bash

# Ensure script fails on any error
set -e

echo "Generating SSL certificates..."

# Create configuration file for OpenSSL
cat > openssl.conf << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
C = IL
ST = Israel
L = Herzelia
O = azure
CN = localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = api-service
EOF

# Generate private key and certificate using the configuration file
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout private.key \
    -out certificate.crt \
    -config openssl.conf

# Adjust permissions
chmod 644 certificate.crt
chmod 600 private.key

# Clean up
rm openssl.conf

echo "Certificates generated successfully!"
echo "For K8s base64 encoding see example command:"
echo "base64 -w 0 certificate.crt > encoded_certificate.txt"
echo "Certificate location: $(pwd)/certificate.crt"
echo "Private key location: $(pwd)/private.key"
