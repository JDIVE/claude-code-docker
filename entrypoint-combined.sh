#!/bin/bash

# Claude Code Docker Entrypoint with code-server

# Kill any existing code-server processes
pkill -f code-server 2>/dev/null || true

# Check if claude command is passed directly
if [ "$1" = "claude" ]; then
    # Direct claude command execution
    shift
    exec claude "$@"
else
    # Default: start code-server as main process
    echo "🚀 Starting code-server..."
    echo "✅ code-server will be available on port 8443 (no auth - protected by Cloudflare Access)"
    echo ""
    echo "🚀 Claude Code Docker Environment Ready!"
    echo ""
    echo "Access options:"
    echo "- Terminal: docker exec -it claude-code /usr/bin/zsh"
    echo "- VS Code: https://claude.openshaw.tech (via Cloudflare Access)"
    echo "- Claude: docker exec -it claude-code claude [command]"
    echo ""
    echo "First time? Run: docker exec -it claude-code claude login"
    echo ""
    
    # Start code-server as the main process (PID 1)
    exec code-server --bind-addr 0.0.0.0:8443 --auth none --disable-telemetry
fi