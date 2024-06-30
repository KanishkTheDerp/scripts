#!/bin/bash

# Define the path for the API key file
api_key_file="$HOME/.pixeldrain_api_key"

# Function to get the API key
get_api_key() {
    if [ ! -f "$api_key_file" ]; then
        read -p "Enter your API key: " api_key
        echo "$api_key" > "$api_key_file"
    else
        api_key=$(cat "$api_key_file")
    fi
}

# Prompt the user for the file name with readline support for auto-completion
read -e -p "Enter the file name to upload: " file_path

# Get the API key
get_api_key

# Define the API endpoint
api_endpoint="https://pixeldrain.com/api/file"

# Notify the user that the upload is starting
echo "Please wait while uploading..."

# Use curl to upload the file using a POST request and capture the response
response=$(curl -X POST -F "file=@$file_path" -u ":$api_key" "$api_endpoint" --silent --write-out "\nHTTP_STATUS:%{http_code}")

# Extract the status code from the response
status_code=$(echo "$response" | grep "HTTP_STATUS" | awk -F: '{print $2}')
upload_response=$(echo "$response" | sed -e 's/HTTP_STATUS\:.*//g')

# Notify the user of completion and display the file link if successful
if [ "$status_code" -eq 200 ]; then
    file_id=$(echo "$upload_response" | jq -r '.id')
    echo "File upload completed."
    echo "File link: https://pixeldrain.com/u/$file_id"
else
    echo "File upload failed with status code $status_code."
    echo "Response: $upload_response"
fi
