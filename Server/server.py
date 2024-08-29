from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

EXTERNAL_API_URL = "http://localhost:11434/api/generate"

# Dictionary to store conversation history for each session
conversation_history = {}

def run_ollama(conversation, model="llama3.1"):
    # Format the conversation history into a single prompt
    prompt = "\n".join(conversation)
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
    session_id = request.json.get('session_id', 'default')  # Use session_id to manage multiple conversations
    user_message = request.json.get('prompt', '')
    
    if not user_message:
        return jsonify({"error": "No prompt provided"}), 400

    # Update the conversation history
    if session_id not in conversation_history:
        conversation_history[session_id] = []
    
    conversation_history[session_id].append(f"User: {user_message}")

    try:
        response = run_ollama(conversation_history[session_id])
        model_response = response.get('response', 'No response found')

        # Update the conversation history with the model's response
        conversation_history[session_id].append(f"Model: {model_response}")

        return jsonify({"response": model_response})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


    # To send requests to server use "curl -X POST http://server_ip:5000/generate -H "Content-Type: application/json" -d '{"session_id": "user1", "prompt": "Replace with prompt"}'""
    # Have to look for the availability of the port used by the flask server
    # The session_id is the number atributed to the session so the server can make the model remember the conversation
    # This probably will be moved for the client side to improve privacy