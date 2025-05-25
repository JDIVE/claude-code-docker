# Claude Code Docker Deployment on GCP

## Prerequisites

- GCP VM with Docker and Docker Compose installed
- Git installed on the VM
- Claude Code Max subscription (for authentication)

## Included Tools

The container comes pre-installed with a comprehensive development environment:

### Core Tools
- **Shell**: ZSH with syntax highlighting, autosuggestions, and completions
- **Editor**: Neovim
- **Multiplexer**: tmux
- **Version Control**: Git with delta (better diffs), lazygit (TUI)
- **Package Manager**: Node.js 20 LTS, Python 3 with pip, uv

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

SSH into your GCP VM:
```bash
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE
```

Clone and enter the repository:
```bash
git clone YOUR_REPO_URL claude-docker
cd claude-docker
```

### 2. Run Setup

```bash
# Make scripts executable
chmod +x setup.sh entrypoint.sh

# Run setup
./setup.sh
```

### 3. First-Time Authentication

```bash
# Access container
docker exec -it claude-code /usr/bin/zsh

# Login to Claude Code with your Max subscription
claude login

# Follow the authentication prompts
# Your credentials will be persisted in the claude-config volume
```

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

- **Configuration**: Stored in `claude-config` volume (includes authentication)
- **Workspace**: Mounted from `./workspace` directory

## Maintenance

### Pull Latest Changes
```bash
git pull
docker-compose build --no-cache
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f claude-code
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

## Performance Tips

1. Mount projects directly:
   ```yaml
   volumes:
     - /path/to/your/project:/home/jamie/workspace/project
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
Check logs with `docker-compose logs claude-code`