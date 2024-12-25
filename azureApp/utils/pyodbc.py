import pyodbc

try:
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=db,1433;"
        "DATABASE=RestaurantDB;"
        "UID=sa;"
        "PWD=YourStrong@Passw0rd",
        timeout=10,
    )
    print("Connection successful!")
except Exception as e:
    print("Connection failed.")
    print("Error:", e)
