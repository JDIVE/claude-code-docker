# Claude Code Docker

Docker container setup for running Claude Code on remote servers via SSH.

## Quick Start

```bash
# Clone repository
git clone [repository-url] claude-docker
cd claude-docker

# Setup and start container
./setup.sh

# First-time login
docker exec -it claude-code claude login
```

## Features

- Ubuntu 24.04 LTS base image
- Node.js 20 LTS
- Claude Code installed globally
- Persistent authentication via Docker volumes
- Clean exec-based access (no SSH daemon in container)
- British English locale configuration

## Usage

### Interactive Session
```bash
docker exec -it claude-code /bin/bash
```

### Direct Commands
```bash
docker exec -it claude-code claude "explain this code"
```

## File Structure

- `Dockerfile` - Container definition with Ubuntu 24.04 and Claude Code
- `docker-compose.yml` - Service configuration with persistent volumes
- `entrypoint.sh` - Container startup script
- `setup.sh` - Quick setup script
- `DEPLOYMENT.md` - Detailed deployment instructions

## Requirements

- Docker and Docker Compose
- Claude Code Max subscription
- Network access to Anthropic APIs

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.