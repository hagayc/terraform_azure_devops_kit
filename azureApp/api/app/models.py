from sqlalchemy import Column, Integer, String, Boolean, Time, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime, time

Base = declarative_base()

class Restaurant(Base):
    __tablename__ = 'restaurants'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100))
    style = Column(String(50))
    address = Column(String(200))
    open_hour = Column(Time)
    close_hour = Column(Time)
    vegetarian = Column(Boolean)

class RequestLog(Base):
    __tablename__ = 'request_logs'
    
    id = Column(Integer, primary_key=True)
    request_time = Column(DateTime, default=datetime.utcnow)
    request_params = Column(String(500))
    response_data = Column(String(500))
