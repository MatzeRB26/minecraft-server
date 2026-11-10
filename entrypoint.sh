#!/usr/bin/env bash
# Entrypoint for the Minecraft server container.
# 1. Writes eula.txt and the settings that come from environment variables
# 2. Fixes the permissions of the data directory
# 3. Starts the server as the unprivileged user "minecraft"
set -euo pipefail

DATA_DIR="/data"
PROPERTIES_FILE="${DATA_DIR}/server.properties"

# Fallback defaults (same as in the Dockerfile), so the server can always start
EULA="${EULA:-false}"
MEMORY="${MEMORY:-2G}"
MOTD="${MOTD:-A Minecraft Server in Docker}"
DIFFICULTY="${DIFFICULTY:-normal}"
GAMEMODE="${GAMEMODE:-survival}"
MAX_PLAYERS="${MAX_PLAYERS:-10}"
VIEW_DISTANCE="${VIEW_DISTANCE:-10}"
ONLINE_MODE="${ONLINE_MODE:-true}"
PVP="${PVP:-true}"
LEVEL_NAME="${LEVEL_NAME:-world}"
RCON_PASSWORD="${RCON_PASSWORD:-}"

# The Minecraft EULA must be accepted explicitly by the user
if [ "${EULA}" != "true" ]; then
  echo "ERROR: The Minecraft EULA (https://www.minecraft.net/eula) has not been accepted."
  echo "Set EULA=true in your .env file to accept it and start the server."
  exit 1
fi

# Sets "key=value" in server.properties (replaces the key if it already exists).
# All other lines stay untouched, so manual changes are kept after a restart.
set_property() {
  local key="${1}"
  local value="${2}"
  local tmp_file="${PROPERTIES_FILE}.tmp"

  grep -v "^${key}=" "${PROPERTIES_FILE}" > "${tmp_file}" || true
  echo "${key}=${value}" >> "${tmp_file}"
  mv "${tmp_file}" "${PROPERTIES_FILE}"
}

cd "${DATA_DIR}"

echo "eula=${EULA}" > eula.txt
touch "${PROPERTIES_FILE}"

set_property "server-port" "25565"
set_property "motd" "${MOTD}"
set_property "difficulty" "${DIFFICULTY}"
set_property "gamemode" "${GAMEMODE}"
set_property "max-players" "${MAX_PLAYERS}"
set_property "view-distance" "${VIEW_DISTANCE}"
set_property "online-mode" "${ONLINE_MODE}"
set_property "pvp" "${PVP}"
set_property "level-name" "${LEVEL_NAME}"

# RCON (remote console) is only enabled when a password is set in .env
if [ -n "${RCON_PASSWORD}" ]; then
  set_property "enable-rcon" "true"
  set_property "rcon.port" "25575"
  set_property "rcon.password" "${RCON_PASSWORD}"
else
  set_property "enable-rcon" "false"
fi

chown -R minecraft:minecraft "${DATA_DIR}"

echo "Starting Minecraft server (memory: ${MEMORY}) ..."
exec setpriv --reuid=minecraft --regid=minecraft --init-groups \
  java -Xms"${MEMORY}" -Xmx"${MEMORY}" -jar /opt/minecraft/server.jar --nogui
