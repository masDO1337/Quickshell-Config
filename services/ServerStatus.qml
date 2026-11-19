pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property FileView file: FileView {
        path: Quickshell.cachePath("servers.json")

        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property list<var> servers: []
        }

        onLoaded: root.check()
    }

    Timer {
        id: checkTimer
        interval: 300000 // 5 minute
        repeat: true
        running: root.file.adapter.servers.length > 0

        onTriggered: root.check()
    }

    property list<var> servers: file.adapter.servers
    property int serverIndex: -1
    property bool checkOne: false

    property Polkit.Message message: Polkit.Message {
        title: "Add Server"
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

            for (const server of root.servers) {
                if (server.host === response.data[0] && Number(server.port) === Number(response.data[1])) {
                    Polkit.error("Server is already in the list")
                    return
                }
            }

            var newServers = {
                host: response.data[0],
                port: Number(response.data[1]),
                lastChecked: null,
                latency: -1,
                serverOn: false,
                mc: {}
            }

            if (root.file.adapter.servers === undefined) {
                root.file.adapter.servers = []
            }

            root.file.adapter.servers.push(newServers)

            Polkit.accept(`Server ${newServers.host}:${newServers.port} is added to the list!`)
        }
    }

    function addServer() {
        message.clear()
        message.inputs[0].value = ''
        message.inputs[1].value = 25565
        Polkit.request(message)
    }

    function removeServer(index) {
        if (index < 0 || index >= root.servers.length) {
            console.log("Invalid server index:", index)
            return
        }

        root.file.adapter.servers.splice(index, 1)
    }

    function check(index = 0, one = false) {
        if (servers.length === 0) return
        if (pcChecker.running || mcStatusProc.running) return

        serverIndex = index
        checkOne = one

        //console.log(`Run server check for index ${serverIndex}`)

        mcStatusProc.execute(servers[serverIndex].host, servers[serverIndex].port)
    }

    Process {
        id: mcStatusProc
        running: false


        function execute(host, port) {
            var command = [
                Quickshell.shellPath("scripts/venv/bin/python"),
                Quickshell.shellPath("scripts/mcserver.py"),
                host,
                port
            ]
            mcStatusProc.exec(command)
        }

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
            if (exitCode !== 0) {
                console.log("Process failed:", exitCode)
                return
            }
            const mc = JSON.parse(buffer)
            root.servers[root.serverIndex].mc = mc

            //console.log(`server index ${root.serverIndex} is ${mc.online ? "Online" : "Offline"}`)

            if (mc.online) {
                root.servers[root.serverIndex].lastChecked = new Date()
                root.servers[root.serverIndex].latency = Math.round(Number(mc.latency_ms)) ?? -1
                root.servers[root.serverIndex].serverOn = mc.online ?? false

                if (root.serverIndex + 1 < root.servers.length && !root.checkOne) {
                    root.check(root.serverIndex + 1)
                }

                if (root.checkOne) root.checkOne = false

            } else {
                pcChecker.execute(root.servers[root.serverIndex].host)
            }
        }
    }

    Process {
        id: pcChecker
        running: false

        function execute(host) {
            var command = [
                "sh", "-c",
                "ping -c 1 -W 2 " + host + " | awk -F'time=' '/time=/{print $2}' | awk '{print $1}'"
            ]
            pcChecker.exec(command)
        }

        stdout: SplitParser {
            onRead: line => {
                const ms = Number(line.trim())

                root.servers[root.serverIndex].serverOn = !isNaN(ms)
                root.servers[root.serverIndex].latency = root.servers[root.serverIndex].serverOn ? Math.round(ms) : -1
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log("Process failed:", exitCode)
            }

            //console.log(`server index ${root.serverIndex} is ${root.servers[root.serverIndex].serverOn ? "Live" : "Dead"}`)

            root.servers[root.serverIndex].lastChecked = new Date()

            if (root.serverIndex + 1 < root.servers.length && !root.checkOne) {
                root.check(root.serverIndex + 1)
            }

            if (root.checkOne) root.checkOne = false
        }
    }
}