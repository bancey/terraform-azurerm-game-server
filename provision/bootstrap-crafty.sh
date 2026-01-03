#!/bin/bash
#set -vxn

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Docker and Docker Compose
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

# Install Docker Compose plugin if not already installed
apt-get install -y docker-compose-plugin

DOMAIN="${domain}"
EMAIL="${email}"

if [ ! -z "$DOMAIN" ] && [ ! -z "$EMAIL" ]; then
    snap install --classic certbot
    certbot certonly --standalone --agree-tos --email "$EMAIL" --no-eff-email --non-interactive -d "$DOMAIN"
fi

# Create directory structure for Crafty
mkdir -p /opt/crafty/{backups,logs,servers,config,import}
cd /opt/crafty

# Create docker-compose.yml for Crafty Controller
cat > docker-compose.yml <<'EOF'
version: '3.8'
services:
  crafty:
    image: registry.gitlab.com/crafty-controller/crafty-4:latest
    container_name: crafty-controller
    restart: unless-stopped
    environment:
      - TZ=UTC
      - PUID=1000
      - PGID=1000
    ports:
      - "8443:8443"  # HTTPS WebUI
      - "8000:8000"   # HTTP WebUI
      - "25565:25565" # Default Minecraft port
      - "25565:25565/udp" # Default Minecraft port UDP
    volumes:
      - ./config:/crafty/app/config
      - ./servers:/crafty/servers
      - ./backups:/crafty/backups
      - ./logs:/crafty/logs
      - ./import:/crafty/import
EOF

# Start Crafty Controller
docker compose up -d

# Create systemd service for Crafty to auto-start on boot
curl -L -o /etc/systemd/system/crafty.service "https://raw.githubusercontent.com/bancey/terraform-azurerm-game-server/main/provision/crafty.service"
systemctl enable crafty
