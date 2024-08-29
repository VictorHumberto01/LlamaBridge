import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Set the model name
model_name = "meta-llama/Llama-3.1-8B"  # Example model, replace with LLaMA 3.1 when available 

# Load the model and tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name, 
    device_map="auto", 
    torch_dtype=torch.float16
)

# Enable gradient checkpointing to reduce memory usage
model.gradient_checkpointing_enable()

# Define the input text. This will be replaced when connected to flask
input_text = "How are you doing?"

# Tokenize the input text and create an attention mask
input_ids = tokenizer.encode(input_text, return_tensors="pt").to('cuda')
attention_mask = torch.ones(input_ids.shape, device=input_ids.device)

# Generate a response with a specified `pad_token_id` and attention mask
with torch.no_grad():
    output = model.generate(
        input_ids,
        attention_mask=attention_mask,
        max_length=50,
        num_return_sequences=1,
        pad_token_id=tokenizer.eos_token_id  # Set `pad_token_id` to `eos_token_id`
    )

# Decode the output to text
response_text = tokenizer.decode(output[0], skip_special_tokens=True)

# Print the response
print(response_text)