pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../PopupWindows"
import "../../services" as Services
import "UI" as UI

Item {
    id: root

    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth

    property string netIface: "offline"
    property string netIp: ""
    property int netType: 0
    property list<url> iconsSource : [
        Qt.resolvedUrl(Quickshell.shellPath("Icons/wifi-slash.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/network-wired.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/wifi.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/globe.svg"))
    ]
    
    onNetIfaceChanged: {
        if (netIface === "offline") netType = 0
        else if (netIface.startsWith("en")) netType = 1
        else if (netIface.startsWith("usb")) netType = 1
        else if (netIface.startsWith("wl")) netType = 2
        else netType = 3
    }

    Process {
        id: netCheck

        command: [
            "sh", "-c",
            "iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i==\"dev\") print $(i+1)}'); " +
            "if [ -n \"$iface\" ]; then " +
            "ip -4 addr show dev \"$iface\" | awk -v i=\"$iface\" '/inet / {print i, $2}' | cut -d/ -f1; " +
            "else echo offline; fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                if (output === "offline" || output.length === 0) {
                    root.netIface = "offline";
                    root.netIp = "";
                    return;
                }

                const parts = output.split(/\s+/);
                root.netIface = parts[0];
                root.netIp = parts[1] || "";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: netCheck.running = true
    }
    
    Component.onCompleted: netCheck.running = true

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: root.iconsSource[root.netType]

        showText: root.netType === 2 && Services.Iwd.connected
        text: Services.Iwd.connectedNetwork
        textColor:"#a6f3b0"

        onClicked: () => networkPanel.toggle()
    }

    Tooltip {
        parentItem: root

        hover: box.mouse.containsMouse && root.netType !== 2

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: `${root.netIface}`
                color: "#fff"
                font.pixelSize: 16
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: root.netIp !== "" ? `IP: ${root.netIp}` : ""
                color: "#bfbfbf"
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }

    NetworkPanel {
        id: networkPanel
        parentItem: root
    }
}