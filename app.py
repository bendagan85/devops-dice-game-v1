from flask import Flask, jsonify, request
import random
import os

app = Flask(__name__)

# Health check endpoint (for K8s liveness/readiness probes)
@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "container": os.uname()[1]}), 200

# Game endpoint: Roll a die
@app.route('/roll', methods=['GET'])
def roll_dice():
    result = random.randint(1, 6)
    return jsonify({
        "message": "You rolled the dice!",
        "result": result,
        "pod_name": os.getenv('HOSTNAME', 'local') # To see load balancing in action
    }), 200

# Home endpoint
@app.route('/', methods=['GET'])
def home():
    return "Welcome to Ben's DevOps Dice Game! Use /roll to play.", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)