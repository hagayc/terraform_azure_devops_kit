# Pick Restaurant System - Deployment Guide

This repository contains a **Restaurant Management System** designed to streamline restaurant operations. The application is architected with a modular approach using **Docker Compose**, ensuring ease of deployment and scalability.

---
## Get AKS K8s context
```
az login
```
```
az account set --subscription 6532e07c-d519-491c-8432-2ee6e63434343
```
```
az aks get-credentials --resource-group azuredevresourcegroup --name devcluster --overwrite-existing
```

## **Architecture Overview**

The system is composed of three primary services:

### **1. Database Service (`db`)**
- **Technology**: SQL Server
- **Responsibilities**:
  - Stores application data, including menu items, orders, and user accounts.
  - Manages transactions securely and efficiently.
- **Configuration**:
  - Environment variables:
    - `ACCEPT_EULA=Y`: Accepts the SQL Server license agreement.
    - `SA_PASSWORD`: Sets the administrator password for the database.
  - Exposes port `1433` for SQL Server.
  - Persistent data storage is enabled through the `mssql_data` volume.

---

### **2. API Service (`api`)**
- **Technology**: Python backend with Flask/FastAPI.
- **Responsibilities**:
  - Implements business logic and acts as the intermediary between the database and frontend.
  - Key functionalities include:
    - **Order Management**: Create, update, and track orders in real-time.
    - **Menu Customization**: Retrieve and update menu items dynamically.
    - **Analytics and Reporting**: Generate sales reports and insights.
  - Environment variables:
    - `DB_CONNECTION`: Specifies the connection string to the SQL Server database.
  - Exposes port `8443` for secure API communication.
  - Shares the `certs` directory for SSL/TLS certificates.

---

### **3. Frontend Service (`frontend`)**
- **Technology**: React or similar frontend framework.
- **Responsibilities**:
  - Provides an interactive web interface for staff and administrators.
  - Integrates securely with the API for real-time data operations.
  - Key features:
    - Staff dashboard for managing orders and reservations.
    - Admin tools for monitoring performance and generating reports.
  - Exposes port `443` for secure web access.
  - Shares the `certs` directory for HTTPS setup.

---

## **Docker Compose Configuration**

### **Networks**
- **`frontend`**: Links the `frontend` and `api` services for user-facing interactions.
- **`backend`**: Links the `api` and `db` services for secure data exchange.

### **Volumes**
- **`mssql_data`**: Ensures persistent storage of SQL Server data files.

---

## **Getting Started**

### **Prerequisites**
- Docker and Docker Compose installed on your system.
- SSL certificates placed in the `certs` directory.

### **Steps to Deploy**
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/restaurant-management-system.git
   cd restaurant-management-system
   ```

2. Start the services:
   ```bash
   docker-compose up --build
   ```

3. Access the application:
   - **Frontend**: `https://localhost:443`
   - **API**: `https://localhost:8443`
   - **Database**: `localhost:1433`

---

## **Environment Variables**

| **Service** | **Variable**             | **Description**                                                 |
|-------------|--------------------------|-----------------------------------------------------------------|
| `db`        | `ACCEPT_EULA`            | Accepts the SQL Server license agreement.                      |
| `db`        | `SA_PASSWORD`            | Administrator password for SQL Server.                         |
| `api`       | `DB_CONNECTION`          | Connection string for the database.                            |

---

## **Folder Structure**

```plaintext
.
├── db/                     # Database Dockerfile and setup scripts
├── api/                    # API source code and Dockerfile
├── frontend/               # Frontend source code and Dockerfile
├── certs/                  # SSL/TLS certificates for secure communication
├── docker-compose.yml      # Docker Compose configuration file
└── README.md               # Project documentation
```
---
## **Business Logic**

### **1. Order Management**
- Facilitates creating, updating, and tracking restaurant orders.
- Ensures that orders are correctly linked to menu items and customer details.

### **2. Menu Management**
- Supports dynamic updates to menu items, prices, and availability.
- Provides an intuitive interface for restaurant administrators.

### **3. Analytics and Reporting**
- Offers APIs for generating real-time reports:
  - Daily and weekly sales summaries.
  - Popular menu items.
  - Revenue trends.

### **4. Security**
- Implements HTTPS for secure communication between services.
- Protects API endpoints with JWT-based authentication.

---

## **Customization**

### Modify Environment Variables
Update the `.env` file or the `environment` section in `docker-compose.yml` to customize the deployment.

### Persistent Data
To ensure data is retained across restarts, the `mssql_data` volume is configured for the database.

---

## **Troubleshooting**

### Database Issues
- Ensure the `SA_PASSWORD` meets SQL Server's password complexity requirements.

### SSL Errors
- Verify that the SSL certificates in the `certs` directory are valid and correctly configured.

### Container Logs
- Check logs for individual containers:
  ```bash
  docker logs <container_name>
  ```

---

## **Future Enhancements**
- Integrate CI/CD pipelines for automated builds and deployments.
- Implement advanced analytics and predictive modeling for sales trends.
- Add multi-language support for the frontend.

---

## **Contributing**
We welcome contributions! Please open an issue or submit a pull request to improve the project.

---

## **License**
This project is licensed under the MIT License. See the `LICENSE` file for more information.
```


