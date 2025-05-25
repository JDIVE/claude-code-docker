# Claude Code Docker

A comprehensive Docker development environment with Claude Code and modern CLI tools.

## Quick Start

```bash
# Clone repository
git clone https://github.com/JDIVE/claude-code-docker.git
cd claude-code-docker

# Setup and start container
./setup.sh

# First-time login
docker exec -it claude-code claude login
```

## Features

- **Base**: Ubuntu 24.04 LTS with British English locale
- **Shell**: ZSH with plugins (syntax highlighting, autosuggestions, completions)
- **Claude Code**: Pre-installed with persistent authentication
- **Development Tools**: Complete CLI toolkit for modern development
- **No SSH**: Clean exec-based access pattern

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

### Interactive Session
```bash
docker exec -it claude-code /usr/bin/zsh
```

### Direct Commands
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

- `Dockerfile` - Complete development environment setup
- `docker-compose.yml` - Service configuration with volumes
- `zshrc` - ZSH configuration with plugins and aliases
- `gitconfig` - Git configuration with delta integration
- `entrypoint.sh` - Container startup script
- `setup.sh` - Quick setup script
- `DEPLOYMENT.md` - Detailed deployment instructions

## Requirements

- Docker and Docker Compose
- Claude Code Max subscription
- Network access to:
  - api.anthropic.com
  - statsig.anthropic.com
  - sentry.io

## Customization

Mount your projects:
```yaml
volumes:
  - /path/to/project:/home/jamie/workspace/project
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