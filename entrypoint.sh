#!/bin/bash

# Claude Code Docker Entrypoint

# Function to handle signals
cleanup() {
    echo "Received signal, shutting down..."
    exit 0
}

trap cleanup SIGTERM SIGINT

# Check if claude command is passed directly
if [ "$1" = "claude" ]; then
    # Direct claude command execution
    shift
    exec claude "$@"
else
    # Default: keep container running for exec access
    echo "🚀 Claude Code Docker Environment Ready!"
    echo ""
    echo "Access with: docker exec -it claude-code /usr/bin/zsh"
    echo "Or run: docker exec -it claude-code claude [command]"
    echo ""
    echo "First time? Run: docker exec -it claude-code claude login"
    
    # Keep container alive
    while true; do
        sleep 3600
    done
fi