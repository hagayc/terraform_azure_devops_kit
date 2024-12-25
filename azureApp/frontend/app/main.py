from flask import Flask, render_template, request, jsonify
import requests
import logging
import ssl
import urllib3
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Enable detailed logging
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

# Configure retry strategy
retry_strategy = Retry(
    total=3,
    backoff_factor=0.1,
    status_forcelist=[500, 502, 503, 504]
)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()
http.mount("https://", adapter)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/search', methods=['POST'])
def search():
    criteria = request.get_json()
    logging.info(f"Received search criteria: {criteria}")
    
    try:
        response = http.post(
            'https://api-service:8443/recommend',
            json=criteria,
            verify=False,
            timeout=5
        )
        logging.info(f"API response status: {response.status_code}")
        logging.info(f"API response content: {response.text}")
        
        return jsonify(response.json())
    except Exception as e:
        logging.error(f"Error making API request: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/stats', methods=['GET'])
def get_stats():
    try:
        response = http.get(
            'https://api-service:8443/request-stats',
            verify=False,
            timeout=5
        )
        return jsonify(response.json())
    except Exception as e:
        logging.error(f"Error getting stats: {str(e)}")
        return jsonify({"error": str(e), "total_requests": 0}), 500

if __name__ == '__main__':
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain('/app/certs/certificate.crt', '/app/certs/private.key')
    app.run(host='0.0.0.0', port=443, ssl_context=context)