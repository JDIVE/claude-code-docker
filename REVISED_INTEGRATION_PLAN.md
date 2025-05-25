# Revised VS Code Server Integration Plan - Modular Approach

## Overview

This revised plan integrates code-server directly into the Claude Code container, maintaining modular Docker Compose files while sharing a common network for inter-service communication. The service will be accessible at claude.openshaw.tech with Cloudflare Access as the sole authentication layer.

## Architecture Changes

### Container Structure
```
claude-code container
├── Claude Code (already installed)
├── code-server (NEW - same container)
├── Home directory (/home/jamie)
└── Single user context (jamie)

cloudflare tunnel container (separate)
└── Routes traffic to claude-code:8443
```

### Benefits of This Approach
1. **Direct Integration**: Use `claude` command directly in code-server terminal
2. **Shared Context**: Same environment, files, and installed tools
3. **Simplified Networking**: No container-to-container communication needed
4. **Modular Compose Files**: Each service maintains its own compose file

## Implementation Plan

### Phase 1: Create Shared Network

Create a network configuration that both compose files can use:

**docker-network-create.sh**:
```bash
#!/bin/bash
# Create shared network for all services
docker network create openshaw-services 2>/dev/null || echo "Network already exists"
```

### Phase 2: Update Claude Code Docker

#### Modified Dockerfile
```dockerfile
FROM ubuntu:24.04

# [... existing Ubuntu setup and packages ...]

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# [... existing Claude Code installation ...]

# Create code-server config directory
RUN mkdir -p /home/jamie/.config/code-server \
    && chown -R jamie:jamie /home/jamie/.config

# Create code-server config with no auth
RUN echo "bind-addr: 0.0.0.0:8443
auth: none
cert: false" > /home/jamie/.config/code-server/config.yaml \
    && chown jamie:jamie /home/jamie/.config/code-server/config.yaml

# [... rest of existing Dockerfile ...]

# Expose code-server port
EXPOSE 8443

# Updated entrypoint to handle both services
COPY entrypoint-combined.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to jamie user
USER jamie
WORKDIR /home/jamie   # Changed from /home/jamie/workspace

# [... Install ZSH plugins ...]
```

#### New docker-compose.yml
```yaml
services:
  claude-code:
    build: .
    container_name: claude-code
    hostname: claude-code
    environment:
      - LANG=en_GB.UTF-8
      - LANGUAGE=en_GB:en
      - LC_ALL=en_GB.UTF-8
    volumes:
      - claude-config:/home/jamie/.config/claude-code
      - code-server-config:/home/jamie/.config/code-server
      # Mount any project directories as needed, e.g.:
      # - /path/to/project:/home/jamie/project
    ports:
      - "127.0.0.1:8443:8443"  # Only expose locally
    networks:
      - openshaw-services
    restart: unless-stopped
    stdin_open: true
    tty: true
    working_dir: /home/jamie

volumes:
  claude-config:
    driver: local
  code-server-config:
    driver: local

networks:
  openshaw-services:
    external: true
```

#### New entrypoint-combined.sh
```bash
#!/bin/bash

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
su - jamie -c "code-server --bind-addr 0.0.0.0:8443 --auth none --disable-telemetry" &
CODE_SERVER_PID=$!
echo "✅ code-server started on port 8443 (no auth - protected by Cloudflare Access)"

# Original Claude Code entrypoint logic
if [ "$1" = "claude" ]; then
    shift
    exec claude "$@"
else
    echo "🚀 Claude Code Docker Environment Ready!"
    echo ""
    echo "Access options:"
    echo "- Terminal: docker exec -it claude-code /usr/bin/zsh"
    echo "- VS Code: https://claude.openshaw.tech (via Cloudflare Access)"
    echo "- Claude: docker exec -it claude-code claude [command]"
    echo ""
    
    # Keep container alive
    while true; do
        sleep 3600
    done
fi
```

#### code-server-config.yaml
```yaml
bind-addr: 0.0.0.0:8443
auth: none
cert: false
```

### Phase 3: Update Cloudflare Tunnel

Update the Cloudflare tunnel docker-compose.yml:

```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    networks:
      - openshaw-services

networks:
  openshaw-services:
    external: true
```

### Phase 4: Cloudflare Configuration Update

Update tunnel configuration to route to the code-server port:
- claude.openshaw.tech → http://claude-code:8443
- Remove any old test configurations (cloud.openshaw.tech, google-mcp.openshaw.tech)

## Deployment Steps

1. **Create shared network**:
   ```bash
   ./docker-network-create.sh
   ```

2. **Update Cloudflare tunnel compose**:
   ```bash
   cd /home/jamie/docker/cloudflare-tunnel
   # Update docker-compose.yml with external network
   docker-compose down
   docker-compose up -d
   ```

3. **Build and deploy updated Claude Code container**:
   ```bash
   cd /home/jamie/docker/claude-code-docker
   # Add new files (Dockerfile, entrypoint-combined.sh, etc.)
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

4. **Update Cloudflare tunnel routing**:
   - Via Cloudflare Dashboard or API
   - Point claude.openshaw.tech to http://claude-code:8443
   - Remove old ingress rules for testing domains

5. **Configure Cloudflare Access** (unchanged from original plan)

## File Structure

```
claude-code-docker/
├── Dockerfile                    # Modified to include code-server
├── docker-compose.yml           # Updated with external network
├── entrypoint-combined.sh       # New: handles both services
├── code-server-config.yaml      # New: code-server configuration
├── .env                         # Environment variables if needed
├── zshrc                        # Existing
├── gitconfig                    # Existing
└── setup.sh                     # Update to create network

cloudflare-tunnel/
├── docker-compose.yml           # Updated with external network
└── .env                         # Existing TUNNEL_TOKEN
```

## Security Considerations

1. **Authentication Flow**:
   - User → Cloudflare Access → Full access
   - Single authentication layer via Cloudflare Zero Trust

2. **Network Security**:
   - code-server only bound to localhost on host
   - Access only through Cloudflare tunnel
   - Shared network isolated from host

## Advantages of This Approach

1. **True Integration**: Claude Code available directly in terminal
2. **Modular Design**: Each service has its own compose file
3. **Easy Updates**: Can update services independently
4. **Shared Environment**: Same tools, config, and workspace
5. **Performance**: No inter-container networking overhead

## Testing Checklist

- [ ] Network creation script works
- [ ] Both services start successfully
- [ ] code-server accessible via Cloudflare
- [ ] Claude command works in code-server terminal
- [ ] File changes reflect in both interfaces
- [ ] Authentication flow works correctly

This approach gives you the best of both worlds - modular service management with tight integration where it matters.