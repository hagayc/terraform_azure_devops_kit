FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .
COPY certs/ /app/certs/

EXPOSE 443

CMD ["python", "main.py"]
