# sudo bash <(curl -Ls "https://raw.githubusercontent.com/jenaze/Ubunto/master/create_service.sh") --name services --script /path/to/app.js --workdir /path --user root

# OR

# sudo bash <(curl -Ls "https://raw.githubusercontent.com/jenaze/Ubunto/master/create_service.sh") -n services -s /path/to/app.js -w /path -u root

#!/bin/bash

# Script to create and enable a Node.js autostart service in Ubuntu
# Supports both interactive and command-line arguments

# Default values
SERVICE_NAME=""
NODE_SCRIPT=""
WORKING_DIR=""
SERVICE_USER="root"
NODE_ENV="production"
RESTART_SEC="50s"

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -n, --name      Service name (required)"
    echo "  -s, --script    Full path to Node.js script (required)"
    echo "  -w, --workdir   Working directory (default: script directory)"
    echo "  -u, --user      User to run as (default: root)"
    echo "  -e, --env       Node environment (default: production)"
    echo "  -r, --restart   Restart delay (default: 50s)"
    echo "  -h, --help      Show this help"
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--name) SERVICE_NAME="$2"; shift ;;
        -s|--script) NODE_SCRIPT="$2"; shift ;;
        -w|--workdir) WORKING_DIR="$2"; shift ;;
        -u|--user) SERVICE_USER="$2"; shift ;;
        -e|--env) NODE_ENV="$2"; shift ;;
        -r|--restart) RESTART_SEC="$2"; shift ;;
        -h|--help) show_help ;;
        *) echo "Unknown parameter: $1"; show_help ;;
    esac
    shift
done

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Interactive prompts for missing arguments
if [ -z "$SERVICE_NAME" ]; then
    read -p "Enter service name (no spaces, no .service extension): " SERVICE_NAME
fi

if [ -z "$NODE_SCRIPT" ]; then
    read -p "Enter full path to Node.js script (e.g., /root/tz/1.js): " NODE_SCRIPT
fi

# Validate script path
if [ ! -f "$NODE_SCRIPT" ]; then
    echo "Error: Node.js script at $NODE_SCRIPT does not exist."
    exit 1
fi

# Set working directory (default to script directory if not provided)
if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR=$(dirname "$NODE_SCRIPT")
    read -p "Enter working directory [default: $WORKING_DIR]: " user_input
    WORKING_DIR=${user_input:-$WORKING_DIR}
fi

# Validate working directory
if [ ! -d "$WORKING_DIR" ]; then
    echo "Error: Working directory $WORKING_DIR does not exist."
    exit 1
fi

if [ -z "$SERVICE_USER" ]; then
    read -p "Run as which user? (default: root): " SERVICE_USER
    SERVICE_USER=${SERVICE_USER:-root}
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    apt-get install -y nodejs
fi

# Create service file
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Node.js Application - ${NODE_SCRIPT}
After=network.target

[Service]
ExecStart=/usr/bin/node ${NODE_SCRIPT}
Restart=on-failure
RestartSec=${RESTART_SEC}
WorkingDirectory=${WORKING_DIR}
Environment=NODE_ENV=${NODE_ENV}
User=${SERVICE_USER}

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start service
systemctl daemon-reload
systemctl enable "$SERVICE_NAME.service"
systemctl start "$SERVICE_NAME.service"

# Verify service status
echo -e "\nService created and started. Here's the status:"
systemctl status "$SERVICE_NAME.service" --no-pager

echo -e "\nService '$SERVICE_NAME' has been configured to start automatically with:"
echo "  - Node.js script: $NODE_SCRIPT"
echo "  - Working directory: $WORKING_DIR"
echo "  - Running as user: $SERVICE_USER"
echo "  - Environment: $NODE_ENV"
echo "  - Auto-restart after: $RESTART_SEC"
echo "Service file created at: $SERVICE_FILE"

# View logs instruction
echo -e "\nTo view logs: journalctl -u $SERVICE_NAME -f"
