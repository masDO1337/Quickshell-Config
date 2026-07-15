pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property FileView file: FileView {
        path: Quickshell.cachePath("server.json")

        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property string host: ""
            property int port: 25565
        }

        onLoaded: root.check()
    }

    readonly property string host: file.adapter.host
    readonly property int port: file.adapter.port

    property bool checking: false
    property bool serverOn: false

    property int latency: -1

    property string status: "Unknown"

    property date lastChecked: new Date(0)

    property var mc: ({})

    property Polkit.Message message: Polkit.Message {
        title: "Set Server"
        message: `Enter IP and Port for server`
        inputs: [
            Polkit.Input {
                prompt: "IP: "
                isPassword: false
            },
            Polkit.Input {
                prompt: "Port: "
                isPassword: false
            }
        ]
        responseCallback: response => {
            if (!response.accepted)
                return
            if (response.data[0] === "") {
                Polkit.error("Empty IP address")
                return
            }

            if (response.data[1] === "") {
                Polkit.error("Empty port")
                return
            }

            const matchIP = response.data[0].match(/^(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$/)
            const matchPort = response.data[1].match(/^(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-9]\d{0,3}|[1-5]\d{4})$/)

            if (!matchIP) {
                Polkit.error("Invalid IP address")
                return
            }

            if (!matchPort) {
                Polkit.error("Invalid port")
                return
            }

            if (response.data[0] === root.host && Number(response.data[1]) === root.port) {
                Polkit.error("Server is already set to this IP and port")
                return
            }

            root.file.adapter.host = response.data[0]
            root.file.adapter.port = Number(response.data[1])
            Polkit.accept(`Server is set to ${root.host}:${root.port}`)
        }
    }

    function setIP() {
        message.clear()
        message.inputs[0].value = root.host
        message.inputs[1].value = root.port
        Polkit.request(message)
    }

    function check() {
        if (host === "" || port <= 0) return
        if (pcChecker.running || mcStatusProc.running) return

        checking = true
        serverOn = false
        latency = -1

        mc = {}

        status = "Checking server..."
        mcStatusProc.running = true
    }

    function checkPc() {
        status = "Server offline, checking PC..."
        pcChecker.running = true
    }

    Process {
        id: mcStatusProc
        running: false

        command: [
            Quickshell.shellPath("scripts/venv/bin/python"),
            Quickshell.shellPath("scripts/mcserver.py"),
            root.host,
            root.port
        ]

        property string buffer: ""

        stdout: SplitParser {
            onRead: line => {
                mcStatusProc.buffer += line
            }
        }

        onStarted: {
            buffer = ""
        }

        onExited: () => {
            try {
                //console.log(buffer)
                root.mc = JSON.parse(buffer)

                if (root.mc.online) {
                    root.status = "Server online"
                    root.serverOn = true
                    root.latency = root.mc.latency_ms
                    root.checking = false
                } else {
                    root.checkPc()
                }

            } catch (e) {
                root.status = "Minecraft info error: " + String(e)
            }

            root.checking = false
            root.lastChecked = new Date()
        }
    }

    Process {
        id: pcChecker
        running: false

        command: [
            "sh", "-c",
            "ping -c 1 -W 2 " + root.host + " | awk -F'time=' '/time=/{print $2}' | awk '{print $1}'"
        ]

        stdout: SplitParser {
            onRead: line => {
                const ms = Number(line.trim())

                root.serverOn = !isNaN(ms)
                root.latency = root.serverOn ? Math.round(ms) : -1
            }
        }

        onExited: () => {
            if (root.mc.error === "Server did not respond with any information!") {
                root.status = "Server online?"
            } else if (root.serverOn) {
                root.status = "PC online, server offline"
            } else {
                root.status = "PC offline"
            }

            root.checking = false
            root.lastChecked = new Date()
        }
    }
}