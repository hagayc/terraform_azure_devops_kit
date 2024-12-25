from fastapi import FastAPI, HTTPException
from sqlalchemy import create_engine, or_, case
from sqlalchemy.orm import sessionmaker
from datetime import datetime, time
import uvicorn
import ssl
import os
import json
from models import Base, Restaurant, RequestLog
import pyodbc
import logging
import pytz
from contextlib import contextmanager
from pydantic import BaseModel
from typing import Optional

# Enable detailed logging
logging.basicConfig(level=logging.DEBUG)
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

odbc_connection_string = (
   "DRIVER={ODBC Driver 17 for SQL Server};"
   "SERVER=db-service,1433;"
   "DATABASE=RestaurantDB;"
   "UID=sa;"
   "PWD=YourStrong@Passw0rd;"
   "Encrypt=Yes;"
   "TrustServerCertificate=Yes;"
   "Connection Timeout=60;"  # Increased timeout
   "CommandTimeout=60;"      # Added command timeout
   "Trusted_Connection=No;"  # Explicitly specify authentication mode
   "MultipleActiveResultSets=True;"  # Allow multiple active result sets
   "ConnectRetryCount=5;"    # Added retry count
   "ConnectRetryInterval=10" # Added retry interval
)

connection_url = f"mssql+pyodbc:///?odbc_connect={odbc_connection_string}"

# Database connection
try:
   engine = create_engine(
       connection_url,
       echo=True,
       pool_pre_ping=True,
       pool_recycle=3600,
       pool_timeout=60,
       pool_size=10,
       max_overflow=20,
       connect_args={
           'connect_timeout': 60
       }
   )
   SessionLocal = sessionmaker(bind=engine)
except Exception as e:
   logging.error(f"Database connection failed: {e}")
   raise

app = FastAPI()

class RecommendationCriteria(BaseModel):
   style: Optional[str]
   vegetarian: Optional[bool]

@contextmanager
def get_session():
   session = None
   try:
       session = SessionLocal()
       # Test the connection
       session.execute('SELECT 1')
       yield session
       session.commit()
   except Exception as e:
       if session:
           session.rollback()
       logging.error(f"Database session error: {e}")
       # Return default values instead of raising
       if "request-stats" in str(e):
           yield {"total_requests": 0}
       else:
           raise
   finally:
       if session:
           session.close()

def is_restaurant_open(open_hour: time, close_hour: time, current_time: time) -> bool:
   """
   Check if a restaurant is currently open
   """
   logging.debug(f"Checking if restaurant is open: open={open_hour}, close={close_hour}, current={current_time}")
   
   # Convert times to minutes since midnight for easier comparison
   curr_minutes = current_time.hour * 60 + current_time.minute
   open_minutes = open_hour.hour * 60 + open_hour.minute
   close_minutes = close_hour.hour * 60 + close_hour.minute
   
   # Handle special case for midnight (00:00)
   if close_minutes == 0:
       close_minutes = 24 * 60  # Set to end of day
   
   logging.debug(f"Minutes since midnight: current={curr_minutes}, open={open_minutes}, close={close_minutes}")
   
   if close_minutes >= open_minutes:
       # Normal case (e.g., 9:00 to 17:00)
       is_open = open_minutes <= curr_minutes <= close_minutes
   else:
       # Crosses midnight (e.g., 22:00 to 02:00)
       is_open = curr_minutes >= open_minutes or curr_minutes <= close_minutes
   
   logging.debug(f"Restaurant is {'open' if is_open else 'closed'}")
   return is_open

@app.get("/request-stats")
async def get_request_stats():
   try:
       with get_session() as session:
           total_requests = session.query(RequestLog).count()
           logging.info(f"Total requests count: {total_requests}")
           return {"total_requests": total_requests}
   except Exception as e:
       logging.error(f"Error getting request stats: {e}")
       return {"error": str(e), "total_requests": 0}

@app.post("/recommend")
async def recommend_restaurant(criteria: RecommendationCriteria):
   try:
       with get_session() as session:
           logging.info(f"Processing recommendation request: {criteria}")
           
           # Build base query
           query = session.query(Restaurant)
           
           # Apply filters
           if criteria.style:
               logging.info(f"Filtering by style: {criteria.style}")
               query = query.filter(Restaurant.style == criteria.style)
           
           if criteria.vegetarian is not None:
               logging.info(f"Filtering by vegetarian: {criteria.vegetarian}")
               query = query.filter(Restaurant.vegetarian == criteria.vegetarian)
           
           # Get all matching restaurants
           restaurants = query.all()
           logging.info(f"Found {len(restaurants)} restaurants matching initial criteria")
           
           if not restaurants:
               result = {"message": "No restaurants found matching your criteria"}
           else:
               # Get current time in Israel
               israel_tz = pytz.timezone('Asia/Jerusalem')
               current_time = datetime.now(israel_tz).time()
               logging.info(f"Current time in Israel: {current_time}")
               
               # Filter and categorize restaurants
               open_restaurants = []
               closed_restaurants = []
               
               for restaurant in restaurants:
                   if is_restaurant_open(restaurant.open_hour, restaurant.close_hour, current_time):
                       open_restaurants.append(restaurant)
                   else:
                       closed_restaurants.append(restaurant)
               
               logging.info(f"Found {len(open_restaurants)} open restaurants")
               
               if not open_restaurants:
                   closed_info = [
                       {
                           "name": r.name,
                           "openHour": r.open_hour.strftime("%H:%M"),
                           "closeHour": r.close_hour.strftime("%H:%M")
                       } for r in closed_restaurants
                   ]
                   result = {
                       "message": "All matching restaurants are currently closed",
                       "current_time": current_time.strftime("%H:%M"),
                       "closed_restaurants": closed_info
                   }
               else:
                   restaurant = open_restaurants[0]
                   logging.info(f"Selected restaurant: {restaurant.name}")
                   result = {
                       "restaurantRecommendation": {
                           "name": restaurant.name,
                           "style": restaurant.style,
                           "address": restaurant.address,
                           "openHour": restaurant.open_hour.strftime("%H:%M"),
                           "closeHour": restaurant.close_hour.strftime("%H:%M"),
                           "vegetarian": restaurant.vegetarian
                       }
                   }

           # Log request and response
           log = RequestLog(
               request_params=json.dumps(criteria.dict()),
               response_data=json.dumps(result)
           )
           session.add(log)
           session.commit()

           return result
           
   except Exception as e:
       logging.error(f"Error processing request: {e}")
       raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
   ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
   ssl_context.load_cert_chain('/app/certs/certificate.crt', '/app/certs/private.key')

   uvicorn.run(
       app,
       host="0.0.0.0",
       port=8443,
       ssl_keyfile="/app/certs/private.key",
       ssl_certfile="/app/certs/certificate.crt"
   )
