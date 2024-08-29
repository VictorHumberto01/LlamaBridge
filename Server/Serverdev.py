import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Set the model name
model_name = "meta-llama/Meta-Llama-3.1-70B"  # Example model, replace with LLaMA 3.1 if available

# Load the model and tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Load the model with device_map to limit memory usage
model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto", torch_dtype=torch.float16)

# Define the input text
input_text = "How are you doing?"

# Tokenize the input text
input_ids = tokenizer.encode(input_text, return_tensors="pt").to('cuda')

# Generate a response with a limited max length
with torch.no_grad():
    output = model.generate(input_ids, max_length=50, num_return_sequences=1)

# Decode the output to text
response_text = tokenizer.decode(output[0], skip_special_tokens=True)

# Print the response
print(response_text)