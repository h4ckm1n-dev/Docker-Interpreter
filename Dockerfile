# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set the working directory in the container
WORKDIR /usr/src/tmp

# Set bash as the default shell with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update apt repository and install required packages
RUN apt-get update && \
  apt-get install -y curl python3 python3-pip zsh git fzf exa sudo && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Starship for a fancy shell prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Open Interpreter via pip
RUN pip3 install open-interpreter

# Add a new user 'developer', give sudo privileges, and set up user environment
RUN useradd -m -s /usr/bin/zsh developer && \
  echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
  chmod 0440 /etc/sudoers.d/developer

# Change to the new user
USER developer

# Set up user-specific configurations
RUN mkdir -p /home/developer/.config/ && \
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/developer/.config/zsh-autosuggestions && \
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /home/developer/.config/zsh-syntax-highlighting

# Copy configuration files into the developer's home directory
# Note: These COPY commands should be adjusted if the config files are user-specific
COPY zshrc /home/developer/.zshrc
COPY starship.toml /home/developer/.config/starship.toml

# Change ownership of the copied files to the new user
USER root
RUN chown -R developer:developer /home/developer
USER developer

# Create a keep-alive script
RUN printf '#!/bin/bash\ntrap "exit 0" SIGTERM SIGINT\nwhile true; do sleep 1; done' > /home/developer/keepalive.sh && \
  chmod +x /home/developer/keepalive.sh

# Set the keep-alive script as the default command
CMD ["/home/developer/keepalive.sh"]
