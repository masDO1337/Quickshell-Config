pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../PopupWindows"
import "../../services" as Services
import "UI" as UI

Item {
    id: root

    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth

    property list<url> icons : [
        Qt.resolvedUrl(Quickshell.shellPath("Icons/wifi-slash.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/network-wired.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/wifi.svg")),
        Qt.resolvedUrl(Quickshell.shellPath("Icons/globe.svg"))
    ]

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: root.icons[Services.Iwd.netType]

        text: Services.Iwd.netType === 2 && Services.Iwd.connected ? Services.Iwd.connectedNetwork : ""
        textColor:"#a6f3b0"

        onClicked: () => { if (Services.Iwd.deviceFound) networkPanel.toggle() }
    }

    Tooltip {
        parentItem: root

        hover: box.mouse.containsMouse && Services.Iwd.netType !== 2

        Item {
            anchors.fill: parent
            implicitWidth: column.implicitWidth + 20
            implicitHeight: column.implicitHeight + 20

            ColumnLayout {
                id: column
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: `${Services.Iwd.netIface}`
                    color: "#fff"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: Services.Iwd.netIp
                    color: "#808080"
                    font.pixelSize: 12
                    visible: Services.Iwd.netIp !== ""
                }
            }
        }
    }

    NetworkPanel {
        id: networkPanel
        parentItem: root
    }
}