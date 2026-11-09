# Minecraft Server in Docker

A self-built Docker image for a vanilla **Minecraft Java Edition server**, deployed with Docker Compose on a cloud VM.

## Table of Contents

- [Description](#description)
- [Repository Contents](#repository-contents)
- [Quickstart](#quickstart)
- [Usage](#usage)
  - [Configuration via environment variables](#configuration-via-environment-variables)
  - [Secrets via .env file](#secrets-via-env-file)
  - [Changing the Minecraft version](#changing-the-minecraft-version)
  - [Changing the port](#changing-the-port)
  - [Persistent data](#persistent-data)
  - [Server console and operator rights](#server-console-and-operator-rights)
  - [Automatic restart](#automatic-restart)
  - [Testing the server](#testing-the-server)
- [Security Notes](#security-notes)

## Description

This repository contains everything needed to build and run your own Minecraft server in a Docker container **without using a pre-built Minecraft image**.

- The image is based on `eclipse-temurin:25-jre` (Java 25 runtime).
- The official `server.jar` is downloaded from Mojang during the build and verified with its SHA1 checksum.
- The server runs as an unprivileged user (`minecraft`), not as root.
- World data and configuration are stored on the host, so nothing is lost when the container is restarted or recreated.
- The container restarts automatically after a crash.
- Default values for all settings make sure the server can always start.

The project was created as part of the DevSecOps course at Developer Akademie.

## Repository Contents

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the image: installs tools, downloads and verifies `server.jar`, creates the `minecraft` user |
| `entrypoint.sh` | Start script: writes `eula.txt` and the settings from environment variables into `server.properties`, then starts the server |
| `docker-compose.yaml` | Defines the `mc-server` service with port, environment, volume and restart policy |
| `.env.example` | Template for the `.env` file with critical settings (e.g. RCON password) |
| `.gitignore` | Excludes `.env`, server data (`data/`) and the Python virtual environment from git |
| `check_server.py` | Python script that checks if the server is reachable (uses [mcstatus](https://github.com/py-mine/mcstatus)) |
| `requirements.txt` | Python dependencies for `check_server.py` |

## Quickstart

**Requirements:** a Linux server with Docker and Docker Compose, port `8888/tcp` open in the firewall, at least 3 GB RAM.

1. Clone the repository on your server:
   ```bash
   git clone https://github.com/MatzeRB26/minecraft-server.git
   cd minecraft-server
   ```
2. Create the `.env` file and set a secure RCON password:
   ```bash
   cp .env.example .env
   sed -i "s|<YOUR_RCON_PASSWORD>|$(openssl rand -hex 16)|" .env
   chmod 600 .env
   ```
3. Build the image and start the server:
   ```bash
   docker compose up -d --build
   ```
4. Wait for the line `Done (...)! For help, type "help"`:
   ```bash
   docker compose logs -f mc-server
   ```
5. Connect with your Minecraft Java client to `<SERVER_IP>:8888`.

## Usage

### Configuration via environment variables

All non-critical settings are set in the `environment` section of `docker-compose.yaml`. On every start, `entrypoint.sh` writes them into `data/server.properties`.

| Variable | Default | Description |
|---|---|---|
| `EULA` | `true` | Accept the [Minecraft EULA](https://www.minecraft.net/eula) (required to start) |
| `MEMORY` | `2G` | Java heap size (`-Xms` and `-Xmx`), e.g. `1G`, `4G` |
| `MOTD` | `A Minecraft Server in Docker` | Message shown in the server list |
| `DIFFICULTY` | `normal` | `peaceful`, `easy`, `normal`, `hard` |
| `GAMEMODE` | `survival` | `survival`, `creative`, `adventure`, `spectator` |
| `MAX_PLAYERS` | `10` | Maximum number of players |
| `VIEW_DISTANCE` | `10` | View distance in chunks (lower = less CPU/RAM) |
| `ONLINE_MODE` | `true` | Check player accounts with Mojang (keep `true` for security) |
| `PVP` | `true` | Allow players to fight each other |
| `LEVEL_NAME` | `world` | Name of the world folder in `data/` |

The defaults are defined in the `Dockerfile` (and as fallback in `entrypoint.sh`), so the server also starts if a variable is missing.

**Example:** creative server with 20 players:

```yaml
environment:
  GAMEMODE: "creative"
  MAX_PLAYERS: "20"
```

Apply the changes:

```bash
docker compose up -d
```

All other settings in `data/server.properties` (e.g. `spawn-protection`) can be edited by hand and are **kept** after a restart. Only the keys listed above are overwritten by the environment variables:

```bash
sudo nano data/server.properties
docker compose restart
```

### Secrets via .env file

Critical settings are **not** stored in the repository. They are read from the `.env` file on the server (see `.env.example`):

| Variable | Description |
|---|---|
| `RCON_PASSWORD` | Password for the remote console. If empty, RCON is disabled. |

RCON listens on port `25575` **inside the container only** and is not published to the internet.

### Changing the Minecraft version

The version is set as build argument in `docker-compose.yaml`:

```yaml
build:
  args:
    MC_VERSION: "<VERSION>"
image: minecraft-server:<VERSION>
```

Rebuild the image:

```bash
docker compose up -d --build
```

Newer Minecraft versions may need a newer Java version. You can check the required version with:

```bash
MANIFEST_URL="https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
VERSION_URL="$(curl -s "${MANIFEST_URL}" | jq -r --arg v "<VERSION>" '.versions[] | select(.id==$v) | .url')"
curl -s "${VERSION_URL}" | jq '.javaVersion.majorVersion'
```

If needed, change the base image in the `Dockerfile` (e.g. `FROM eclipse-temurin:<JAVA_VERSION>-jre`).

### Changing the port

The server is published on port `8888` of the host. To use another port, change the left side of the port mapping in `docker-compose.yaml`:

```yaml
ports:
  - "<HOST_PORT>:25565"
```

### Persistent data

The folder `./data` on the host is mounted to `/data` in the container. It contains the world, `server.properties`, whitelist, ops and logs. Because of this, the game state survives `docker compose down` / `up` and server reboots.

Backup example:

```bash
docker compose stop
sudo tar -czf "mc-backup-$(date +%F).tar.gz" data/
docker compose start
```

### Server console and operator rights

Attach to the server console:

```bash
docker attach mc-server
```

Now you can type server commands, e.g. give yourself operator rights:

```
op <YOUR_MINECRAFT_USERNAME>
```

Leave the console with **Ctrl+P**, then **Ctrl+Q**. Do **not** press Ctrl+C, this stops the server.

### Automatic restart

The service uses `restart: unless-stopped`. The container is restarted automatically after a crash and after a reboot of the server. It is only not restarted if you stop it yourself with `docker compose stop` or `down`.

Test (simulates a crash):

```bash
sudo kill -9 "$(docker inspect -f '{{.State.Pid}}' mc-server)"
sleep 10
docker compose ps
docker inspect -f '{{.RestartCount}}' mc-server
```

### Testing the server

`check_server.py` checks from any computer if the server is reachable:

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python check_server.py <SERVER_IP>:8888
```

Example output:

```
Server <SERVER_IP>:8888 is online
Version: 26.3
Players: 0/10
MOTD:    Matze's Minecraft Server
Latency: 95 ms
```

## Security Notes

- No passwords, tokens, usernames or IP addresses are stored in this repository.
- Secrets are passed to the container via the `.env` file, which is ignored by git.
- The server runs as the unprivileged user `minecraft` inside the container.
- The downloaded `server.jar` is verified with the SHA1 checksum from Mojang.
- Only the game port is published; RCON stays internal.
