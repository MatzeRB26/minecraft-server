# Base image: Eclipse Temurin Java Runtime (Minecraft 26.3 needs Java 25)
FROM eclipse-temurin:25-jre

# Minecraft version to download (change it to build another version)
ARG MC_VERSION=26.3

# Default values for the server settings, so the server can always start.
# They can be overwritten via environment variables (.env / docker-compose.yaml).
# EULA is false by default: the user has to accept it explicitly.
ENV EULA=false \
    MEMORY=2G \
    MOTD="A Minecraft Server in Docker" \
    DIFFICULTY=normal \
    GAMEMODE=survival \
    MAX_PLAYERS=10 \
    VIEW_DISTANCE=10 \
    ONLINE_MODE=true \
    PVP=true \
    LEVEL_NAME=world

# Install the tools needed to download the server
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create an unprivileged user, so the server does not run as root
RUN groupadd --system minecraft \
    && useradd --system --gid minecraft --home-dir /data --shell /usr/sbin/nologin minecraft \
    && mkdir -p /opt/minecraft /data

# Download the official server.jar from Mojang and verify its SHA1 checksum
# Note: "$v" is a jq variable inside the jq filter, not a shell variable
RUN set -eux; \
    MANIFEST_URL="https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"; \
    VERSION_URL="$(curl -fsSL "${MANIFEST_URL}" | jq -r --arg v "${MC_VERSION}" '.versions[] | select(.id==$v) | .url')"; \
    SERVER_URL="$(curl -fsSL "${VERSION_URL}" | jq -r '.downloads.server.url')"; \
    SERVER_SHA1="$(curl -fsSL "${VERSION_URL}" | jq -r '.downloads.server.sha1')"; \
    curl -fsSL -o /opt/minecraft/server.jar "${SERVER_URL}"; \
    echo "${SERVER_SHA1}  /opt/minecraft/server.jar" | sha1sum -c -

# Copy the start script (remove Windows line endings and make it executable)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# World, configs and logs are stored here -> mounted as a volume
VOLUME ["/data"]
WORKDIR /data

# Minecraft default port inside the container
EXPOSE 25565

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
