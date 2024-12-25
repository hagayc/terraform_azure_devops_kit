import pyodbc
from sqlalchemy import create_engine
import logging

# Enable detailed logging
logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Create pyodbc connection string
odbc_connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=db,1433;"
    "DATABASE=RestaurantDB;"
    "UID=sa;"
    "PWD=YourStrong@Passw0rd;"
    "Encrypt=Yes;"
    "TrustServerCertificate=Yes"
)


connection_url = f"mssql+pyodbc:///?odbc_connect={odbc_connection_string}"
#engine = create_engine(connection_url, echo=True)

try:
    print("Creating engine...")
    engine = create_engine(connection_url, echo=True)
    print("Testing connection...")
    with engine.connect() as conn:
        print("Connection successful!")
except Exception as e:
    print("Connection failed.")
    print("Detailed error:")
    print(e)
