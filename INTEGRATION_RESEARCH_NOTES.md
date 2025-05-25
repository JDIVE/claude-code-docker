# VS Code Server Integration Research Notes

## Key Findings from GCP VM Exploration

### Current Setup Details
- **Cloudflare Tunnel**: Already running and configured for cloud.openshaw.tech
- **Current routing**: cloud.openshaw.tech → http://host.docker.internal:8000 (no service currently)
- **Docker networks**: Separate networks for claude-code and cloudflare containers
- **Tunnel uses**: host.docker.internal to reach host services

### Technical Discoveries

1. **Cloudflare Tunnel Configuration**:
   - Tunnel ID: c272d31b-9228-4ed6-9238-eb3d33b188ec
   - Connected to multiple Cloudflare edges (lhr13, lhr15, lhr01, lhr20)
   - Configuration updates via API (currently at version 3)
   - Also configured: google-mcp.openshaw.tech

2. **Docker Network Architecture**:
   - claude-code-docker_claude-net (Claude Code container)
   - cloudflare-tunnel_default (Cloudflare container)
   - Need to unify networks for inter-container communication

3. **VS Code Server Options Comparison**:
   
   **code-server (Recommended)**:
   - LinuxServer.io image provides best Docker integration
   - Built-in authentication (password/token)
   - Mature platform with extensive documentation
   - Supports Docker mods for additional functionality
   - Port 8443 by default

   **OpenVSCode Server**:
   - Lighter weight, closer to upstream VS Code
   - Minimal authentication (connection token only)
   - Less customization options
   - Port 3000 by default

### Security Considerations

1. **Current State**: No authentication on tunnel endpoints
2. **Proposed State**: 
   - Cloudflare Access for primary authentication
   - code-server password as secondary layer
   - All traffic encrypted via Cloudflare

### Integration Challenges Identified

1. **Network Unification**: Need to combine Docker networks
2. **Port Conflicts**: Ensure no conflicts with existing services
3. **Volume Permissions**: Match UIDs between containers
4. **Cloudflare Config**: Update tunnel to point to new service

### Quick Implementation Checklist

- [ ] Create unified docker-compose.yml
- [ ] Set up .env file with passwords
- [ ] Update Cloudflare tunnel configuration
- [ ] Configure Cloudflare Access application
- [ ] Test authentication flow
- [ ] Document access procedures

### Resource Requirements

Based on current VM specs (4 vCPU, 16GB RAM):
- code-server: ~500MB RAM, minimal CPU
- Current usage allows comfortable headroom
- Network bandwidth: 1-5 Mbps during active use

### Alternative Configurations Considered

1. **Separate Deployments**: Keep services isolated (rejected - complicates networking)
2. **Nginx Proxy**: Add reverse proxy layer (rejected - unnecessary complexity)
3. **Direct Port Exposure**: Skip Cloudflare (rejected - security risk)

### Cloudflare Access Setup Notes

From Cloudflare Dashboard:
1. Zero Trust → Access → Applications → Add Application
2. Select "Self-hosted"
3. Configure authentication methods (Email, Google, GitHub)
4. Set session duration (recommend 24 hours)
5. No additional client software needed

### Testing Strategy

1. Deploy to separate test compose file first
2. Verify authentication flow
3. Test Claude Code integration
4. Check performance metrics
5. Validate security headers