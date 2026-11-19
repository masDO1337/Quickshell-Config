#!/usr/bin/env python3

import json
import sys
import asyncio
from dataclasses import asdict, is_dataclass
from typing import Any

from mcstatus import JavaServer

def json_default(value: Any):
    if is_dataclass(value):
        return asdict(value)

    if hasattr(value, "__dict__"):
        return value.__dict__

    return str(value)

def detect_server_type(status):
    raw = status.raw
    version = status.version.name.lower()

    # Forge / NeoForge modern handshake
    if "forgeData" in raw:
        channels = raw["forgeData"].get("channels", [])
        mods = raw["forgeData"].get("mods", [])

        for ch in channels:
            if "neoforge" in ch.get("res", "").lower():
                return "NeoForge"

        return "Forge"

    # Older Forge
    if "modinfo" in raw:
        t = raw["modinfo"].get("type", "").lower()
        if "neoforge" in t:
            return "NeoForge"
        return "Forge"

    # Fabric servers often expose fabric in version
    if "fabric" in version:
        return "Fabric"

    # Spigot family
    if "paper" in version:
        return "Paper"
    if "purpur" in version:
        return "Purpur"
    if "spigot" in version:
        return "Spigot"
    if "bukkit" in version:
        return "Bukkit"

    return "Vanilla"

async def query(host, port):
    server = JavaServer.lookup(f"{host}:{port}")
    status = await server.async_status()

    channels = 0
    mods = 0

    # Check for Forge/NeoForge data
    if "forgeData" in status.raw:
        channels = len(status.raw["forgeData"].get("channels", []))
        mods = len(status.raw["forgeData"].get("mods", []))

    if "modinfo" in status.raw:
        mods = len(status.raw["modinfo"].get("modList", []))

    # Debugging: print(status.raw)
    #print(status.raw)

    # Build the output data structure
    data = {
        "online": True,
        "latency_ms": status.latency,
        "version": {
            "name": status.version.name,
            "type": detect_server_type(status),
            "protocol": status.version.protocol,
        },
        "channels": channels,
        "mods": mods,
        "players": {
            "online": status.players.online,
            "max": status.players.max,
            "sample": [
                {
                    "name": player.name,
                    "id": player.id,
                }
                for player in (status.players.sample or [])
            ],
        },
        "motd": status.motd.to_plain(),
        "icon": status.icon,
        "enforces_secure_chat": getattr(
            status, "enforces_secure_chat", None
        ),
    }

    # Output the data as JSON
    print(json.dumps(data, ensure_ascii=False, default=json_default))


if __name__ == "__main__":
    try:
        host = sys.argv[1]
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 25565
        asyncio.run(query(host, port))
    except Exception as e:
        print(json.dumps({
            "online": False,
            "error": str(e),
        }, ensure_ascii=False))