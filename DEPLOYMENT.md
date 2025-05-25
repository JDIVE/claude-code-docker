# Claude Code Docker Deployment

## Prerequisites

- Server/VM with Docker installed (with Compose plugin v2)
- Git installed on the server
- Claude Code Max subscription (for authentication)
- (Optional) Cloudflare Tunnel for VS Code web access

## Included Tools

The container comes pre-installed with a comprehensive development environment:

### Core Tools
- **Shell**: ZSH with syntax highlighting, autosuggestions, and completions
- **Editor**: Neovim + VS Code Server (browser-based)
- **Multiplexer**: tmux
- **Version Control**: Git with delta (better diffs), lazygit (TUI)
- **Package Manager**: Node.js 20 LTS, Python 3 with pip, uv
- **Claude Code**: Integrated in both terminal and VS Code

### CLI Enhancements
- **eza**: Modern replacement for ls with icons
- **bat**: Cat with syntax highlighting
- **fd**: Fast alternative to find
- **ripgrep**: Fast grep replacement
- **fzf**: Fuzzy finder for files and commands
- **zoxide**: Smarter cd command
- **jq/yq**: JSON/YAML processors

### Development Tools
- **GitHub CLI**: Manage repos and PRs from terminal
- **HTTPie**: User-friendly HTTP client
- **shellcheck**: Shell script linter
- **tldr**: Simplified man pages
- **htop**: Interactive process viewer
- **ncdu**: Disk usage analyzer

## Deployment Steps

### 1. Clone the Repository

SSH into your server and clone the repository:
```bash
git clone https://github.com/JDIVE/claude-code-docker.git
cd claude-code-docker
```

### 2. Setup Network and Container

```bash
# Make scripts executable
chmod +x setup.sh docker-network-create.sh

# Create shared Docker network
./docker-network-create.sh

# Run setup
./setup.sh
```

### 3. First-Time Authentication

```bash
# Login to Claude Code with your Max subscription
docker exec -it claude-code claude login

# Follow the authentication prompts
# Your credentials will be persisted in the claude-config volume
```

### 4. Access VS Code Server (Optional)

If using Cloudflare Tunnel:
- Navigate to your configured domain
- Authenticate via Cloudflare Access
- VS Code opens in your browser with Claude integration

## Usage

### Interactive Session
```bash
# Enter container for extended work
docker exec -it claude-code /usr/bin/zsh

# Use Claude Code normally
claude "help me with this project"
```

### Direct Command Execution
```bash
# Run commands directly from the VM
docker exec -it claude-code claude "explain this codebase"
docker exec -it claude-code claude code "add error handling"
```

## Persistent Data

- **Claude Configuration**: Stored in `claude-config` volume
- **VS Code Configuration**: Stored in `code-server-config` volume
- **Working Directory**: `/home/jamie` (mount project directories as needed)

## Maintenance

### Pull Latest Changes
```bash
git pull
docker compose build --no-cache
docker compose up -d
```

### View Logs
```bash
docker compose logs -f claude-code
```

### Backup Configuration
```bash
docker run --rm -v claude-docker_claude-config:/data -v $(pwd):/backup ubuntu \
  tar czf /backup/claude-config-backup.tar.gz -C /data .
```

## Network Requirements

The container needs access to:
- api.anthropic.com
- statsig.anthropic.com  
- sentry.io

For Cloudflare Tunnel setup:
- Configure tunnel to route to `container-name:8443`
- Set up Cloudflare Access for authentication

## Performance Tips

1. Mount projects directly:
   ```yaml
   volumes:
     - /path/to/your/project:/home/jamie/project
   ```

2. Resource limits in docker-compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2'
         memory: 4G
   ```

3. For automation, use:
   ```bash
   docker exec -it claude-code claude --dangerously-skip-permissions "your command"
   ```

## Troubleshooting

### Permission issues:
```bash
docker exec -it claude-code sudo chown -R jamie:jamie /home/jamie
```

### Authentication errors:
Re-run `claude login` inside the container

### Container not starting:
Check logs with `docker compose logs claude-code`