# LLaMA Bridge Chat Interface

## Overview

This project provides a server-client chat interface using the LLaMA model. The server is built in Python using Flask and communicates with a client that can be used in other systems. The project is designed to handle and manage conversations, sending requests to the LLaMA model for responses.

## Features

- **Swift Client**: A native swift client can be run in MacOS.
- **Python Client**: A client written in Python to handle other systems while native clients are being developed.
- **Flask Server**: The server is built with Flask and requires JSON handling capabilities.
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

3. **Start the Server**:
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
Enter server_ip to connect
**Session_id**: Refers to the conversation id used to track history.
