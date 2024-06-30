#!/bin/bash

# Define the path for the API key file
api_key_file="$HOME/.pixeldrain_api_key"

# Function to install the script in /usr/bin and set permissions
install_script() {
    script_path="/usr/bin/upload"

    # Check if the script is already installed
    if [ -f "$script_path" ]; then
        echo "Script is already installed."
        return
    fi

    # Copy the script to /usr/bin
    sudo cp "$0" "$script_path"

    # Set executable permissions
    sudo chmod +x "$script_path"

    echo "Script installed successfully in $script_path."
    echo "You can now run 'upload' from anywhere."
    exit 0
}

# Function to check and install jq if necessary
install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        if [ "$(uname)" == "Darwin" ]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install jq
            else
                echo "Homebrew is not installed. Please install Homebrew to proceed."
                exit 1
            fi
        elif [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            sudo apt-get update && sudo apt-get install -y jq
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            sudo yum install -y jq
        else
            echo "Unsupported OS. Please install jq manually."
            exit 1
        fi
    fi
}

# Check if running with sudo and install the script if needed
if [ "$(id -u)" != "0" ]; then
    echo "Script requires superuser privileges to install."
    echo "Re-running with sudo to install..."
    sudo bash "$0" "$@"
    exit $?
fi

# Function to get the API key
get_api_key() {
    if [ ! -f "$api_key_file" ]; then
        read -p "Enter your API key: " api_key
        echo "$api_key" > "$api_key_file"
    else
        api_key=$(cat "$api_key_file")
    fi
}

# Function to upload the file
upload_file() {
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
    if [ "$status_code" -eq 201 ]; then
        file_id=$(echo "$upload_response" | jq -r '.id')
        echo "File upload completed."
        echo "File link: https://pixeldrain.com/u/$file_id"
    else
        echo "File upload failed with status code $status_code."
        echo "Response: $upload_response"
    fi
}

# Main script flow
if [ "$1" == "--install" ]; then
    install_script
fi

# Ensure jq is installed
install_jq

# If not installing, proceed with uploading the file
upload_file
