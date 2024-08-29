import requests
import json

# Simple client to test encryption and functions of the server-side script

def check_stored_info():
    try:
        with open('data.json', 'r') as file:
            dataload = json.load(file)
            if "Stored" in dataload and dataload["Stored"] == "True":
                print("Success")
                return dataload.get("server_ip")  # Return server IP if stored
            else:
                print("No information stored yet, please provide when asked")
                return None
    except FileNotFoundError:
        print("No information stored yet, please provide when asked")
        return None
    except json.JSONDecodeError:
        print("Error reading JSON data from file")
        return None

def get_server():
    server_ip = input("Enter the server IP: ")
    data = {
        "server_ip": server_ip,
        "Stored": "True"
    }
    
    with open('data.json', 'w') as file:
        json.dump(data, file, indent=4)

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

def main():
    server_ip = check_stored_info()
    
    if not server_ip:
        get_server()  # Prompt user to input server IP if not stored
        server_ip = check_stored_info()  # Read the new server IP from the file

    session_id = input("Enter the session ID: ")
    prompt = input("Enter the prompt: ")
    
    response = send_request(session_id, prompt, server_ip)
    if response is not None:
        print("Response from server:", json.dumps(response, indent=2))

if __name__ == "__main__":
    main()