FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install system dependencies, build tools, and Microsoft ODBC drivers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        build-essential \
        g++ && \
    # Import the Microsoft repository GPG key
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    # Add Microsoft repository
    curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    # Update package list and remove conflicting ODBC packages before installing msodbcsql18
    rm -rf /var/lib/apt/lists/* && apt-get clean all && apt-get update && \
    apt-get purge -y libodbc2 libodbccr2 unixodbc-common && \
    ACCEPT_EULA=Y apt-get install -y apt-utils msodbcsql17 unixodbc-dev

    # Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y procps iputils-ping telnet vim
# Copy application files
COPY app/ .
COPY certs/ certs/

EXPOSE 8443

CMD ["python", "main.py"]
