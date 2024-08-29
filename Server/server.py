from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

EXTERNAL_API_URL = "http://localhost:11434/api/generate"

def run_ollama(prompt, model="llama3"):
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    response = requests.post(EXTERNAL_API_URL, json=payload)
    if response.status_code == 200:
        return response.json()  # Return the entire JSON response
    else:
        raise Exception(f"External API error: {response.text}")

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    prompt = data.get('prompt', '')
    if not prompt:
        return jsonify({"error": "No prompt provided"}), 400

    try:
        response = run_ollama(prompt)
        return jsonify(response)  # Return the entire JSON response from the external API
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)