#!/bin/bash

# Claude Code Docker Setup Script

set -e

echo "Setting up Claude Code Docker environment..."

# Create workspace directory if it doesn't exist
mkdir -p workspace

# Build the Docker image
echo "Building Docker image..."
docker-compose build

# Create and start the container
echo "Starting container..."
docker-compose up -d

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Login to Claude Code (first time only):"
echo "   docker exec -it claude-code claude login"
echo ""
echo "2. Use Claude Code:"
echo "   • Interactive session: docker exec -it claude-code /bin/bash"
echo "   • Direct command: docker exec -it claude-code claude [command]"
echo ""
echo "Your authentication will be persisted in the claude-config volume."
echo ""