# Claude Code Docker

A comprehensive Docker development environment with Claude Code, VS Code Server, and modern CLI tools.

## Quick Start

```bash
# Clone repository
git clone https://github.com/JDIVE/claude-code-docker.git
cd claude-code-docker

# Create shared Docker network
./docker-network-create.sh

# Setup and start container
./setup.sh

# First-time login (for Claude Code)
docker exec -it claude-code claude login
```

## Features

- **Base**: Ubuntu 24.04 LTS with British English locale
- **Shell**: ZSH with plugins (syntax highlighting, autosuggestions, completions)
- **Claude Code**: Pre-installed with persistent authentication
- **VS Code Server**: Browser-based VS Code with Claude integration
- **Development Tools**: Complete CLI toolkit for modern development
- **Shared Environment**: VS Code and Claude Code in the same container

## Included Tools

### Core Development
- Git + GitHub CLI
- Neovim
- tmux
- Python 3 + pip + uv
- Node.js 20 LTS

### Enhanced CLI Tools
- **eza** - Better ls with icons
- **bat** - Better cat with syntax highlighting
- **fd** - Better find
- **ripgrep** - Better grep
- **fzf** - Fuzzy finder
- **zoxide** - Smarter cd
- **delta** - Better git diffs
- **lazygit** - Git TUI

### Utilities
- jq/yq - JSON/YAML processing
- HTTPie - HTTP client
- htop - Process viewer
- tldr - Simplified man pages
- shellcheck - Shell linter
- ncdu - Disk usage analyzer

## Usage

### VS Code Server (Browser)
Access VS Code in your browser (requires Cloudflare Access setup):
- Navigate to your configured domain
- Use the integrated terminal to run `claude` commands

### Interactive Terminal Session
```bash
docker exec -it claude-code /usr/bin/zsh
```

### Direct Claude Commands
```bash
docker exec -it claude-code claude "explain this code"
```

### Common Aliases
- `cc` → `claude`
- `ccc` → `claude code`
- `lg` → `lazygit`
- `ll` → `eza -la`
- `g` → `git`

## File Structure

- `Dockerfile` - Complete development environment setup with code-server
- `docker-compose.yml` - Service configuration with external network
- `zshrc` - ZSH configuration with plugins and aliases
- `gitconfig` - Git configuration with delta integration
- `entrypoint-combined.sh` - Combined startup script for both services
- `docker-network-create.sh` - Network setup script
- `setup.sh` - Quick setup script
- `DEPLOYMENT.md` - Detailed deployment instructions

## Requirements

- Docker with Compose plugin (v2)
- Claude Code Max subscription
- (Optional) Cloudflare Access for VS Code web access
- Network access to:
  - api.anthropic.com
  - statsig.anthropic.com
  - sentry.io

## Customization

Mount your projects:
```yaml
volumes:
  - /path/to/project:/home/jamie/project
```

Set resource limits:
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.