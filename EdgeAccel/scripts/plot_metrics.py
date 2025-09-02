import csv
import json
from flask import Flask, jsonify, send_from_directory

app = Flask(__name__)
metrics_file = 'results/performance_metrics.csv'

@app.route('/api/metrics')
def get_metrics():
    metrics = []
    with open(metrics_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            metrics.append(row)
    return jsonify(metrics)

@app.route('/')
def serve_dashboard():
    return send_from_directory('../web', 'perf_dashboard.html')

if __name__ == '__main__':
    app.run(debug=True, port=5000)
