FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

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

# Create a non-root user for Claude Code
RUN useradd -m -s /bin/bash jamie \
    && usermod -aG sudo jamie \
    && echo "jamie ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create necessary directories
RUN mkdir -p /home/jamie/.config/claude-code \
    && mkdir -p /home/jamie/workspace \
    && chown -R jamie:jamie /home/jamie

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

# Switch to jamie user
USER jamie
WORKDIR /home/jamie/workspace

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [""]