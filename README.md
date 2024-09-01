<p align="center">
<img style="align:center;" src="https://github.com/vitub/LlamaBridge/blob/main/Resources/Icon.png" alt="LLamaBridge Logo" width="200" />
</p>

<h1 align="center">LlamaBridge</h1>
<h3 align="center">A server-client chat interface for the LlaMA model.</h3>
<p align="center">

## Overview
This project provides a server-client chat interface utilizing the LLaMA model. The server, built in Python using Flask, communicates with a client that can be integrated into other systems. The project is designed to manage and handle conversations, sending requests to the LLaMA model for responses. The main objective is to create a solution for running the model on a local server and connecting it to a user-friendly client interface.

## Features

- **Swift Client**: A native swift client can be run in MacOS.
- **Python Client**: A client written in Python to handle other systems while native clients are being developed.
- **Flask Server**: The server is built with Flask and requires JSON handling capabilities. **Note that the server script is still in development and it's not ready for daily use**
- **Conversation Management**: The client handles session-based conversations, ensuring each session's history is preserved.
- **Ollama Integration**: The server utilizes the Ollama library to communicate with the LLaMA model.

## Requirements

- **Python 3.8+**
- **Flask**: `pip install flask`
- **Ollama**: Ensure Ollama is installed and configured.
- **JSON**: Python's built-in JSON module is used.

## Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/vitub/LlamaBridge.git
    cd LlamaBridge
    ```

2. **Install the required Python packages**:
    ```bash
    pip install flask
    ```

3. **Ensure Ollama is installed**:
    Ollama must be installed on your system to run the server.

4. **Pull model with Ollama**:
   ```bash
   ollama pull llama3.1
   ```

## Usage

### Running the Server

1. **Run Ollama api**:
   ```bash
      ollama serve
    ```

2. **Start the Server**:
    Run the server using the following command:
    ```bash
    python server.py
    ```

### Using swift client:
The client can be downloaded in the releases tab.
All clients will prompt the server_ip.

## Using Python client:
```bash
  cd Client
  python client.py
```
- **Server_ip**: IP used to connect to the main host server
- **Session_id**: The `session_id` is a unique identifier that keeps each conversation separate, allowing the AI to remember and continue specific chats without mixing them up. This can be any unique combination chosen by you.
