pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: ""
    property bool deviceFound: device !== ""
    property bool powered: false
    property bool connected: false
    property string connectedNetwork: ""
    property string statusText: "Loading..."
    property var networks: []
    property var knownNetworks: []

    function shQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function setPowered(on) {
        if (!deviceFound)
            return

        powerProc.command = [
            "bash", "-lc",
            "iwctl device " + shQuote(device) + " set-property Powered " + (on ? "on" : "off")
        ]

        powerProc.running = true
    }

    function refresh() {
        if (!deviceFound)
            return
        statusText = "Refresh..."
        statusProc.running = true
        networksProc.running = true
    }

    Timer {
        id: refreshTimer
        running: false
        interval: 2000
        onTriggered: {
            root.refresh()
        }
    }

    function scan() {
        if (!deviceFound)
            return

        statusText = "Scanning..."
        scanProc.running = true
    }
    
    property var message: Polkit.Message {
        property string device: root.device
        property string ssid: ""

        title: "Wi-Fi password"
        message: `Enter password for network: ${ssid}`
        supplementaryMessage: ""
        inputs: [
            Polkit.Input {
                prompt: "Password: "
                isPassword: true
            }
        ]
        responseCallback: response => {
            if (!response.accepted){
                root.statusText = "Password canceled!"
                return
            }
            connectProc.command = [
                "bash", "-lc",
                "iwctl --passphrase " + root.shQuote(response.data[0])
                + " station " + root.shQuote(device)
                + " connect " + root.shQuote(ssid)
            ]
            connectProc.running = true
        }
    }

    function connect(ssid) {
        if (!deviceFound || ssid === "") return
        if (ssid === connectedNetwork) return

        statusText = "Connecting to " + ssid + "..."

        if (!isKnown(ssid)) {
            message.ssid = ssid
            message.responseRequired = true
            message.supplementaryMessage = ""
            Polkit.request(message)
        } else {
            connectProc.command = [
                "bash", "-lc",
                "iwctl station " + shQuote(device) + " connect " + shQuote(ssid)
            ]
            connectProc.running = true
        }
    }

    function disconnect() {
        if (!deviceFound)
            return

        disconnectProc.running = true
    }

    function parseBool(value) {
        value = String(value).toLowerCase()
        return value === "yes" || value === "true" || value === "on"
    }

    function isKnown(ssid) {
        return knownNetworks.indexOf(ssid) !== -1
    }

    function remove(ssid) {
        if (!deviceFound || ssid === "") return
        if (!isKnown(ssid)) return

        statusText = ssid + " is removed"


        deleteProc.command = [
            "bash", "-lc",
            "iwctl known-networks " + shQuote(ssid) + " forget"
        ]
        deleteProc.running = true
    }

    Process {
        id: getDeviceProc
        command: [
            "bash", "-lc",
            "iwctl device list | sed 's/\\x1b\\[[0-9;]*m//g' | awk '"
            + "NF >= 5 && $NF == \"station\" { print $1 \"|\" $3; exit }"
            + "'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim()

                if (out === "") {
                    root.device = ""
                    root.powered = false
                    root.connected = false
                    root.connectedNetwork = ""
                    root.statusText = "No WiFi device"
                    root.networks = []
                    return
                }

                const parts = out.split("|")

                root.device = parts[0] ?? ""
                root.powered = root.parseBool(parts[1] ?? "off")

                if (!root.powered) {
                    root.connected = false
                    root.connectedNetwork = ""
                    root.statusText = "WiFi off"
                    root.networks = []
                    return
                }

                scanProc.running = true
                knownNetworksProc.running = true
            }
        }
    }

    Process {
        id: powerProc

        onExited: {
            getDeviceProc.running = true
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-lc", "iwctl station " + root.shQuote(root.device) + " scan"]

        onExited: {
            refreshTimer.running = true
        }
    }

    Process {
        id: statusProc
        command: ["bash", "-lc", "iwctl station " + root.shQuote(root.device) + " show"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.connected = false
                root.connectedNetwork = ""

                let skip = 0
                const lines = this.text.split("\n")

                for (const line of lines) {
                    const clean = line.trim()

                    if (line.length === 0 || skip <= 3) {
                        skip ++
                        continue
                    }

                    if (clean.startsWith("Connected network")) {
                        root.connectedNetwork = clean.replace("Connected network", "").trim()
                        root.connected = root.connectedNetwork.length > 0
                    }
                }

                if (root.device === "") {
                    root.statusText = "No WiFi device"
                } else if (!root.powered) {
                    root.statusText = "WiFi off"
                } else if (root.connected) {
                    root.statusText = root.connectedNetwork
                } else {
                    root.statusText = "Not connected"
                }
            }
        }
    }

    Process {
        id: networksProc
        command: ["bash", "-lc", "iwctl station " + root.shQuote(root.device) + " get-networks"]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = []
                const lines = this.text.split("\n")

                for (let line of lines) {
                    line = line.replace(/\x1b\[[0-9;]*m/g, "")
                    line = line.trim()

                    if (
                        line.length === 0 ||
                        line.startsWith("Available networks") ||
                        line.startsWith("Network name") ||
                        line.startsWith("---")
                    ) continue

                    // iwd can mark connected network with ">"
                    if (line.startsWith(">"))
                        line = line.substring(1).trim()
                    
                    // Example-ish:
                    // MyWifi          psk        ****
                    // OpenWifi        open       ***
                    const match = line.match(/^(.+?)\s{2,}(\S+)\s+(.+)$/)

                    if (!match)
                        continue

                    result.push({
                        ssid: match[1].trim(),
                        security: match[2].trim(),
                        signal: match[3].trim()
                    })
                }

                result.sort((a, b) => a.ssid.localeCompare(b.ssid))
                root.networks = result
            }
        }
    }

    Process {
        id: knownNetworksProc

        command: [
            "bash", "-lc",
            "iwctl known-networks list 2>/dev/null || true"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = []
                const lines = this.text.split("\n")

                for (let line of lines) {
                    line = line.replace(/\x1b\[[0-9;]*m/g, "")
                    line = line.trim()

                    if (
                        line.length === 0 ||
                        line.startsWith("Known Networks") ||
                        line.startsWith("Name") ||
                        line.startsWith("---")
                    ) continue

                    // iwd known-networks list is usually one name per row
                    // But keep only first column if table formatting exists.
                    const name = line.replace(/\s{2,}.*/, "").trim()

                    if (name.length > 0)
                        result.push(name)
                }

                result.sort((a, b) => a.localeCompare(b))
                root.knownNetworks = result
            }
        }
    }

    Process {
        id: connectProc

        property string out: ""

        stdout: StdioCollector {
            onStreamFinished: {
                connectProc.out = this.text.trim()
                connectProc.out = connectProc.out.replace(/\x1b\[[0-9;]*m/g, "").replace(/^\s+|\s+$/g, "")
                if (connectProc.out !== "") {
                    Polkit.error(connectProc.out)
                    root.statusText = connectProc.out
                }
            }
        }

        onExited: {
            if (connectProc.out.length === 0) {
                Polkit.accept("Connected")
                knownNetworksProc.running = true
                refreshTimer.running = true
            }
        }
    }

    Process {
        id: disconnectProc
        command: ["bash", "-lc", "iwctl station " + root.shQuote(root.device) + " disconnect"]

        onExited: {
            root.refresh()
        }
    }

    Process {
        id: deleteProc

        onExited: {
            knownNetworksProc.running = true
            root.refresh()
        }
    }

    Component.onCompleted: getDeviceProc.running = true
}