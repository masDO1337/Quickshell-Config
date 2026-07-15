#!/usr/bin/env python3

import json
import sys
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

def query(host, port):
    server = JavaServer.lookup(f"{host}:{port}")
    status = server.status()

    channels = 0
    mods = 0

    if "forgeData" in status.raw:
        channels = len(status.raw["forgeData"].get("channels", []))
        mods = len(status.raw["forgeData"].get("mods", []))

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

    return data


if __name__ == "__main__":
    try:
        host = sys.argv[1]
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 25565

        print(json.dumps(query(host, port), ensure_ascii=False, default=json_default))
    except Exception as e:
        print(json.dumps({
            "online": False,
            "error": str(e),
        }, ensure_ascii=False))