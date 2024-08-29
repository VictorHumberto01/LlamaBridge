import requests
import json
import os

# Load conversations from a file
def load_conversations(filename='conversations.json'):
    if os.path.exists(filename):
        with open(filename, 'r') as file:
            return json.load(file)
    else:
        return {}

# Save conversations to a file
def save_conversations(conversations, filename='conversations.json'):
    with open(filename, 'w') as file:
        json.dump(conversations, file, indent=4)

# Function to format the conversation history into a single string
def format_conversation(conversation):
    formatted = ""
    for entry in conversation:
        formatted += f"User: {entry['prompt']}\nAI: {entry['response']}\n"
    return formatted

# Add a new prompt-response pair to the conversation
def add_to_conversation(session_id, prompt, response, filename='conversations.json'):
    conversations = load_conversations(filename)
    
    if session_id not in conversations:
        conversations[session_id] = []

    conversations[session_id].append({
        "prompt": prompt,
        "response": response
    })

    save_conversations(conversations, filename)

# Send request to server
def send_request(session_id, prompt, server_ip):
    url = f"http://{server_ip}:5000/generate"
    headers = {"Content-Type": "application/json"}
    data = {
        "session_id": session_id,
        "prompt": prompt
    }
    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()  # Raise an exception for HTTP errors
        return response.json()
    except requests.exceptions.RequestException as e:
        print("Error sending request:", str(e))
        return None

# Main function to handle the conversation flow
def main():
    server_ip = input("Enter the server IP: ")
    session_id = input("Enter the session ID: ")

    # Load the current conversation history for the session
    conversations = load_conversations()
    conversation_history = conversations.get(session_id, [])

    # Continuously prompt the user for input and send it to the server
    while True:
        prompt = input("Enter the prompt (type 'exit' to quit or 'change' to change session_id): ")
        if prompt.lower() == 'exit':
            break

        if prompt.lower() == 'change':
            # Save the current conversation history back to the conversations dictionary
            conversations[session_id] = conversation_history
            
            session_id = input("Enter the new session ID: ")
            conversation_history = conversations.get(session_id, [])
            
            # If the session ID does not exist, initialize it
            if not conversation_history:
                conversations[session_id] = []
                conversation_history = conversations[session_id]

        # Format the conversation history plus the new prompt
        formatted_history = format_conversation(conversation_history)
        full_prompt = f"{formatted_history}User: {prompt}\nAI:"

        # Send the formatted history and new prompt to the server
        response = send_request(session_id, full_prompt, server_ip)
        
        if response is not None:
            response_text = response.get("response", "")
            print("Response from server:", response_text)
            
            # Save the new prompt and response to the conversation history
            add_to_conversation(session_id, prompt, response_text)
            
            # Update the conversation history in memory
            conversation_history.append({
                "prompt": prompt,
                "response": response_text
            })

if __name__ == "__main__":
    main()