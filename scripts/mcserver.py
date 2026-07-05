#!/usr/bin/env python3

import json
import sys
from mcstatus import JavaServer


def query(host, port):
    server = JavaServer.lookup(f"{host}:{port}")
    status = server.status()

    return status.raw


if __name__ == "__main__":
    try:
        host = sys.argv[1]
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 25565

        print(json.dumps(query(host, port), ensure_ascii=False))
    except Exception as e:
        print(json.dumps({
            "online": False,
            "error": str(e),
        }, ensure_ascii=False))