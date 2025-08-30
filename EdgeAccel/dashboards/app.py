from flask import Flask, send_from_directory
from flask_socketio import SocketIO
import time
import random
import threading

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/')
def index():
    return send_from_directory('../web', 'index.html')

@app.route('/chart.js')
def chart_js():
    return send_from_directory('../scripts', 'chart.js')

# Simulated backend stream
def fusion_data_stream():
    while True:
        timestamp = time.strftime('%H:%M:%S')
        fusion_value = random.uniform(0.8, 1.2)   # Replace with real UART/AXI data
        model_value  = 1.0                        # Replace with real Python model prediction

        socketio.emit('new_data', {
            'timestamp': timestamp,
            'fusion_value': fusion_value,
            'model_value': model_value
        })

        time.sleep(1)

if __name__ == '__main__':
    threading.Thread(target=fusion_data_stream).start()
    socketio.run(app, host='0.0.0.0', port=5000)
