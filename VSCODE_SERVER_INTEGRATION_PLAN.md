# VS Code Server Integration Plan for Claude Code Docker

## Executive Summary

This plan outlines the integration of VS Code Server into the existing Claude Code Docker environment, secured via Cloudflare Access on your GCP VM (cloud.openshaw.tech).

## Current State Analysis

### Existing Infrastructure
- **GCP VM**: Ubuntu 24.04 LTS (34.39.23.46)
- **Docker Services Running**:
  - Claude Code container (claude-code-docker_claude-net network)
  - Cloudflare Tunnel container (cloudflare-tunnel_default network)
- **Cloudflare Tunnel**: Configured for cloud.openshaw.tech → http://host.docker.internal:8000
- **Authentication**: Currently no service at port 8000

## Recommended Solution: code-server

### Why code-server over OpenVSCode Server?
1. **Better Security**: Built-in password/token authentication
2. **Mature Platform**: More established with better documentation
3. **Cloudflare Access Ready**: Proven integration patterns
4. **Resource Efficient**: Works well with existing 4 vCPU, 16GB RAM specs
5. **Extension Compatibility**: Better support for marketplace/private extensions

## Architecture Design

### Network Topology
```
Internet → Cloudflare Access → Cloudflare Tunnel → VS Code Server → Claude Code Container
                                     ↓
                             (cloud.openshaw.tech)
                                     ↓
                            Docker Host (port 8080)
                                     ↓
                           code-server container
                                     ↓
                          Shared volume with Claude Code
```

### Container Architecture
1. **Shared Network**: Create a shared Docker network for all services
2. **Volume Sharing**: VS Code server accesses same workspace as Claude Code
3. **User Consistency**: Same user (jamie) across containers

## Implementation Plan

### Phase 1: Docker Compose Modifications

Create new `docker-compose.yml` combining all services:

```yaml
version: '3.8'

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
      - workspace:/home/jamie/workspace
    networks:
      - openshaw-net
    restart: unless-stopped
    stdin_open: true
    tty: true

  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - PASSWORD=${CODE_SERVER_PASSWORD} # From .env file
      - SUDO_PASSWORD=${CODE_SERVER_SUDO_PASSWORD}
      - DEFAULT_WORKSPACE=/config/workspace
      - PROXY_DOMAIN=cloud.openshaw.tech
    volumes:
      - code-server-config:/config
      - workspace:/config/workspace
    ports:
      - "8080:8443"
    networks:
      - openshaw-net
    restart: unless-stopped

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    networks:
      - openshaw-net
    depends_on:
      - code-server

volumes:
  claude-config:
    driver: local
  code-server-config:
    driver: local
  workspace:
    driver: local

networks:
  openshaw-net:
    driver: bridge
```

### Phase 2: Cloudflare Configuration

1. **Update Tunnel Configuration**:
   - Point cloud.openshaw.tech to code-server:8443
   - Use internal Docker networking (no host.docker.internal needed)

2. **Configure Cloudflare Access**:
   - Create Access Application for cloud.openshaw.tech
   - Set authentication policy (Email OTP, Google, GitHub)
   - Configure session duration (24 hours recommended)

### Phase 3: Security Enhancements

1. **Authentication Layers**:
   - Layer 1: Cloudflare Access (primary authentication)
   - Layer 2: code-server password (secondary/backup)

2. **Network Security**:
   - All containers on isolated Docker network
   - No direct port exposure except through Cloudflare
   - Firewall rules on GCP (only SSH + Cloudflare IPs)

3. **Access Control**:
   - Cloudflare Access policies for user management
   - Optional: Service tokens for automation

### Phase 4: Integration Features

1. **Shared Workspace**:
   - Both Claude Code and VS Code access same files
   - Real-time collaboration possible

2. **Terminal Access**:
   - VS Code terminal can execute Claude commands
   - Direct integration with Claude Code CLI

3. **Extension Recommendations**:
   - Claude AI extension for VS Code
   - Git integration
   - Docker extension for container management

## Migration Steps

1. **Backup Current Setup**:
   ```bash
   docker exec -it claude-code claude logout  # Save auth state
   docker cp claude-code:/home/jamie/.config/claude-code ./claude-backup
   ```

2. **Deploy New Configuration**:
   ```bash
   # Stop existing containers
   docker-compose down
   
   # Deploy combined setup
   docker-compose -f docker-compose.combined.yml up -d
   ```

3. **Configure Cloudflare Access**:
   - Login to Cloudflare Dashboard
   - Navigate to Zero Trust → Access → Applications
   - Create new self-hosted application for cloud.openshaw.tech
   - Configure authentication methods

4. **Test & Verify**:
   - Access https://cloud.openshaw.tech
   - Authenticate via Cloudflare Access
   - Verify VS Code loads with workspace
   - Test Claude Code integration

## Considerations & Risks

### Performance
- VS Code server adds ~500MB RAM usage
- Minimal CPU impact unless compiling
- Network bandwidth for web UI (~1-5 Mbps active use)

### Security Risks
- Exposed development environment (mitigated by Cloudflare Access)
- Shared filesystem between containers
- Sudo access in VS Code terminal

### Maintenance
- Regular updates for code-server image
- Monitor Cloudflare Access logs
- Backup configuration volumes

## Alternative Approaches

### Option B: OpenVSCode Server
- Lighter weight but less secure
- Would require custom authentication solution
- Less mature Cloudflare Access integration

### Option C: Official VS Code Server
- Requires VS Code license
- More complex setup
- Better Microsoft integration

## Recommendation

Proceed with **code-server** implementation using the combined Docker Compose approach. This provides:
- Seamless integration with existing Claude Code setup
- Enterprise-grade security via Cloudflare Access
- Minimal configuration changes
- Best user experience

## Next Steps

1. Review and approve this plan
2. Create combined Docker Compose file
3. Test in staging (optional)
4. Schedule maintenance window for migration
5. Deploy and configure Cloudflare Access
6. Document access procedures for users

## Estimated Timeline

- Planning & Approval: Current
- Implementation: 2-3 hours
- Testing & Refinement: 1-2 hours
- Total: Half day with buffer for issues