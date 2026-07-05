pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property ListModel packages: ListModel {}
    property int packagesPacman: 0
    property int packagesAUR: 0

    property bool showUpdates: packages.count > 0

    property bool checking: pacmanUpdates.running || aurUpdates.running

    property Timer updateTimer: Timer {
        interval: 1000 * 60 * 60 * 2 // every 2 h
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.checkAllUpdates()
    }

    property Process pacmanUpdates: Process {
        command: ["checkupdates"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.parseUpdates(text, "pacman")
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // checkupdates exits non-zero when no updates sometimes, 
                // so do not treat stderr as fatal here.
                if (text.trim().length > 0)
                    console.log("Update check stderr:", text)
            }
        }
    }

    property Process aurUpdates: Process {
        command: ["paru", "-Qua"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.parseUpdates(text, "aur")
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.log("AUR update check stderr:", text)
            }
        }
    }

    property Process update: Process {
        command: ["kitty", "-e", "paru"]
        running: false

        onExited: root.checkAllUpdates()
    }

    function checkAllUpdates() {
        packages.clear()

        pacmanUpdates.running = true
        aurUpdates.running = true
    }

    function sortPackagesByName() {
        const items = []

        for (let i = 0; i < packages.count; i++) {
            const pkg = packages.get(i)
            items.push({ name: pkg.name || "", old: pkg.old || "", new: pkg.new || "", from: pkg.from || "" })
        }

        items.sort((a, b) => a.name.localeCompare(b.name))

        packages.clear()

        for (const item of items) {
            packages.append({
                name: item.name,
                old: item.old,
                new: item.new,
                from: item.from
            })
        }
    }

    function parseUpdates(text, source) {
        const lines = text
            .split("\n")
            .map(line => line.trim())
            .filter(line => line.length > 0)

        if (source === "pacman") packagesPacman = lines.length
        if (source === "aur") packagesAUR = lines.length

        for (const line of lines) {
            // Format:
            // package-name old-version -> new-version
            const match = line.match(/^(.+?)\s+(.+?)\s+->\s+(.+)$/)

            if (!match)
                continue

            packages.append({
                name: match[1],
                old: match[2],
                new: match[3],
                from: source
            })
        }
        sortPackagesByName()
    }

    function runUpdate(packageName) {
        if (packageName !== "") {
            update.command = ["kitty", "-e", "paru", "-S", packageName]
            update.running = true
        } else {
            update.command = ["kitty", "-e", "paru"]
            update.running = true
        }
    }
}