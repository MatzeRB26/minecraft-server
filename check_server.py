"""Check if the Minecraft server is reachable and print its status.

Usage:
    python check_server.py <SERVER_IP>:<PORT>
"""
import sys

from mcstatus import JavaServer


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python check_server.py <SERVER_IP>:<PORT>")
        return 2

    address = sys.argv[1]

    try:
        server = JavaServer.lookup(address)
        status = server.status()
    except Exception as error:
        print(f"Server {address} is NOT reachable: {error}")
        return 1

    print(f"Server {address} is online")
    print(f"Version: {status.version.name}")
    print(f"Players: {status.players.online}/{status.players.max}")
    print(f"MOTD:    {status.motd.to_plain()}")
    print(f"Latency: {status.latency:.0f} ms")
    return 0


if __name__ == "__main__":
    sys.exit(main())
