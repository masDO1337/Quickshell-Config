pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool checking: false

    property string serverHost: serverStatsFile.adapter.serverHost
    onServerHostChanged: {
        if (serverHost !== "") check()
    }

    property int serverPort: serverStatsFile.adapter.serverPort
    onServerPortChanged: {
        if (serverHost !== "") check()
    }

    readonly property FileView serverStatsFile: FileView {
        path: Quickshell.cachePath("server.json")

        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property string serverHost: ""
            property int serverPort: 25565
        }
    }

    property bool serverAlive: false
    property int serverLatency: -1

    property bool pcAlive: false

    property string status: "Unknown"
    property string error: ""

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

            if (response.data[0] === root.serverHost && Number(response.data[1]) === root.serverPort) {
                Polkit.error("Server is already set to this IP and port")
                return
            }

            root.serverStatsFile.adapter.serverHost = response.data[0]
            root.serverStatsFile.adapter.serverPort = Number(response.data[1])
            Polkit.accept(`Server is set to ${response.data[0]}:${response.data[1]}`)
        }
    }

    function setIP() {
        message.clear()
        message.inputs[0].value = root.serverHost
        message.inputs[1].value = root.serverPort
        Polkit.request(message)
    }

    function check() {
        if (serverHost === "" || serverPort <= 0)
            return
        
        if (serverChecker.running || pcChecker.running || mcStatusProc.running)
            return

        serverAlive = false
        serverLatency = -1
        pcAlive = false

        checking = true
        error = ""
        status = "Checking server..."

        serverChecker.command = [
            "sh", "-c",
            "start=$(date +%s%3N); " +
            "timeout 2 bash -c '</dev/tcp/" + root.serverHost + "/" + root.serverPort + "' >/dev/null 2>&1; " +
            "code=$?; " +
            "end=$(date +%s%3N); " +
            "echo \"$code $((end - start))\""
        ]

        serverChecker.running = true
    }

    function checkPc() {
        status = "Server offline, checking PC..."

        pcChecker.command = [
            "sh", "-c",
            "ping -c 1 -W 2 " + root.serverHost + " | awk -F'time=' '/time=/{print $2}' | awk '{print $1}'"
        ]

        pcChecker.running = true
    }

    function getMinecraftInfo() {
        status = "Getting Minecraft info..."

        mcStatusProc.command = [
            Quickshell.shellPath("scripts/venv/bin/python"),
            Quickshell.shellPath("scripts/mcserver.py"),
            root.serverHost,
            root.serverPort
        ]

        mcStatusProc.running = true
    }

    Component.onCompleted: check()

    Process {
        id: serverChecker
        running: false

        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(" ")
                const code = Number(parts[0])
                const ms = Number(parts[1])

                root.serverAlive = code === 0
                root.serverLatency = root.serverAlive ? ms : -1

                if (root.serverAlive) {
                    root.pcAlive = true
                    root.getMinecraftInfo()
                } else {
                    root.checkPc()
                }
                root.lastChecked = new Date()
            }
        }
    }

    Process {
        id: mcStatusProc

        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: line => {
                mcStatusProc.buffer += line
            }
        }

        onStarted: {
            buffer = ""
        }

        onExited: (exitCode, exitStatus) => {
            try {
                const data = JSON.parse(buffer)
                console.log(JSON.stringify(data))
                
                root.mc = data
                root.status = "Server online"
            } catch (e) {
                root.serverAlive = false
                root.error = String(e)
                root.status = "Minecraft info error"
            }

            root.checking = false
            root.lastChecked = new Date()
        }
    }

    Process {
        id: pcChecker
        running: false

        stdout: SplitParser {
            onRead: line => {
                const ms = Number(line.trim())

                root.pcAlive = !isNaN(ms)
                root.serverLatency = root.pcAlive ? Math.round(ms) : -1
            }
        }

        onExited: () => {
            if (root.serverAlive) {
                root.status = "Server online"
            } else if (root.pcAlive) {
                root.status = "PC online, Minecraft server offline"
            } else {
                root.status = "PC offline"
            }

            root.checking = false
            root.lastChecked = new Date()
        }
    }
}