FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and development tools
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
    wget \
    git \
    build-essential \
    sudo \
    locales \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    # Shell and terminal tools
    zsh \
    tmux \
    # System monitoring
    htop \
    ncdu \
    # Text processing
    jq \
    ripgrep \
    fd-find \
    bat \
    tree \
    # Network tools
    httpie \
    rsync \
    # Development tools
    neovim \
    shellcheck \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install additional tools from GitHub releases
# Note: fd-find is already installed via apt, just create symlink
RUN ln -s $(which fdfind) /usr/local/bin/fd && \
    curl -L https://github.com/eza-community/eza/releases/latest/download/eza_$(uname -m)-unknown-linux-gnu.tar.gz | tar -xz -C /usr/local/bin && \
    curl -L https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')_Linux_x86_64.tar.gz | tar -xz -C /usr/local/bin lazygit && \
    curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq && \
    curl -L https://github.com/junegunn/fzf/releases/download/v0.58.0/fzf-0.58.0-linux_amd64.tar.gz | tar -xz -C /usr/local/bin && \
    curl -L https://github.com/dandavison/delta/releases/latest/download/delta-$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": "\K[^"]*')-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /tmp && mv /tmp/delta-*/delta /usr/local/bin/ && rm -rf /tmp/delta-* && \
    curl -L https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-$(curl -s https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | grep -Po '"tag_name": "v\K[^"]*')-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

# Generate locale
RUN locale-gen en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB:en
ENV LC_ALL=en_GB.UTF-8

# Install Node.js 20 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install Python tools
RUN pip3 install --break-system-packages \
    uv \
    tldr

# Create a non-root user with zsh as default shell
RUN useradd -m -s /usr/bin/zsh jamie \
    && usermod -aG sudo jamie \
    && echo "jamie ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create necessary directories
RUN mkdir -p /home/jamie/.config/claude-code \
    && mkdir -p /home/jamie/.config/code-server \
    && mkdir -p /home/jamie/.local/bin \
    && chown -R jamie:jamie /home/jamie

# Create code-server config with no auth
RUN echo "bind-addr: 0.0.0.0:8443" > /home/jamie/.config/code-server/config.yaml && \
    echo "auth: none" >> /home/jamie/.config/code-server/config.yaml && \
    echo "cert: false" >> /home/jamie/.config/code-server/config.yaml && \
    chown jamie:jamie /home/jamie/.config/code-server/config.yaml

# Copy configuration files
COPY --chown=jamie:jamie zshrc /home/jamie/.zshrc
COPY --chown=jamie:jamie gitconfig /home/jamie/.gitconfig

# Copy entrypoint script
COPY entrypoint-combined.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose code-server port
EXPOSE 8443

# Switch to jamie user
USER jamie
WORKDIR /home/jamie

# Install ZSH plugins
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /home/jamie/.zsh/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /home/jamie/.zsh/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions /home/jamie/.zsh/zsh-completions

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [""]