#!/bin/bash

# Claude Code Docker Entrypoint with code-server

# Function to handle signals
cleanup() {
    echo "Received signal, shutting down services..."
    if [ -n "$CODE_SERVER_PID" ]; then
        kill $CODE_SERVER_PID
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start code-server in background
echo "🚀 Starting code-server..."
# Start code-server as jamie user with no auth
if [ "$(whoami)" = "jamie" ]; then
    code-server --bind-addr 0.0.0.0:8443 --auth none --disable-telemetry &
    CODE_SERVER_PID=$!
else
    su jamie -c "code-server --bind-addr 0.0.0.0:8443 --auth none --disable-telemetry" &
    CODE_SERVER_PID=$!
fi
echo "✅ code-server started on port 8443 (no auth - protected by Cloudflare Access)"

# Check if claude command is passed directly
if [ "$1" = "claude" ]; then
    # Direct claude command execution
    shift
    exec claude "$@"
else
    # Default: keep container running for exec access
    echo "🚀 Claude Code Docker Environment Ready!"
    echo ""
    echo "Access options:"
    echo "- Terminal: docker exec -it claude-code /usr/bin/zsh"
    echo "- VS Code: https://claude.openshaw.tech (via Cloudflare Access)"
    echo "- Claude: docker exec -it claude-code claude [command]"
    echo ""
    echo "First time? Run: docker exec -it claude-code claude login"
    
    # Keep container alive
    while true; do
        sleep 3600
    done
fi