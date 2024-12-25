FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies and Microsoft SQL Server tools including sqlcmd
RUN apt-get update && \
    apt-get install -y curl apt-transport-https gnupg && \
    # Add Microsoft package repository key and list
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg && \
    curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev && \
    # Add mssql-tools to PATH for convenience
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/profile && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure the mssql-tools is available in the PATH
ENV PATH="$PATH:/opt/mssql-tools/bin"

# Copy SQL script and entrypoint
COPY init.sql .
COPY entrypoint.sh .

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
