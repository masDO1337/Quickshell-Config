pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property bool running: false
    property string tempPath: ""
    property string outputPath: ""

    property var callback: () => {}

    Process {
        id: screenshotProcess
        running: false

        onExited: () => {
            console.log(root.outputPath)
            Quickshell.execDetached(["sh", "-c", `wl-copy < "${root.outputPath}"`])
            Quickshell.execDetached(["sh", "-c", "notify-send -a quickshell -c screenshot -u low -i", root.outputPath, "Screenshot Saved."])
            root.callback()
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text === "") return
                console.log(this.text)
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text === "") return
                console.log(this.text)
            }
        }

    }

    function start(screen: ShellScreen) {
        if (running) return
        running = true

        const path = Quickshell.cachePath(`screenshot-${Date.now()}.png`)
        tempPath = path
        
        Quickshell.execDetached(["grim", "-g", `${screen.x},${screen.y} ${screen.width}x${screen.height}`, path])
    }

    function cancel() {
        if (!running) return
        running = false

        Quickshell.execDetached(["rm", tempPath])
    }

    function processScreenshot(target: vector4d, callback) {
        if (!running) return

        root.callback = callback

        const scale = Hyprland.focusedMonitor.scale
        const scaledTarget = target.times(scale)

        const picturesDir = Quickshell.env("HOME") + "/Pictures/Screenshots"

        const timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss")
        outputPath = `${picturesDir}/Screenshot-${timestamp}_${Math.floor(Math.random() * 1000000)}.png`

        screenshotProcess.command = ["sh", "-c",
            `magick "${tempPath}" -crop ${scaledTarget.z}x${scaledTarget.w}+${scaledTarget.x}+${scaledTarget.y} "${outputPath}"`
        ]

        screenshotProcess.running = true
    }
}