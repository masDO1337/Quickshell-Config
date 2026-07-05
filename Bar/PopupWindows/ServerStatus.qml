import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "UI" as UI

Tooltip {
    Item {
        implicitWidth: Math.max(280, mainColumn.implicitWidth)
        implicitHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            anchors.fill: parent
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Server"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: `${Services.ServerStatus.serverHost ?? ""}`
                    color: "#bfbfbf"
                    font.pixelSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: `${Services.ServerStatus.serverPort ?? ""}`
                    color: "#bfbfbf"
                    font.pixelSize: 12
                }

                UI.Button {
                    showIcon: false
                    showText: true
                    text: "IP"
                    textSize: 12

                    onClicked: () => Services.ServerStatus.setIP()
                }

                UI.Button {
                    showIcon: false
                    showText: true
                    text: "Refresh"
                    textSize: 12

                    onClicked: () => Services.ServerStatus.check()
                }
            }

            Text {
                text: `${Services.ServerStatus.status}`
                color: "#bfbfbf"
                font.pixelSize: 12
            }

            Text {
                text: `Lateney: ${Services.ServerStatus.serverLatency} ms`
                color: "#bfbfbf"
                font.pixelSize: 12
                visible: Services.ServerStatus.serverLatency >= 0
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: "#1e1e1e"
            }

            Text {
                text: `${Services.ServerStatus.mc.description ?? ""}`
                color: 'white'
                font.pixelSize: 16
                visible: text.length > 0
            }

            Text {
                text: `${Services.ServerStatus.mc.players?.online ?? ""}/${Services.ServerStatus.mc.players?.max ?? ""}`
                color: '#19960e'
                font.pixelSize: 12
                visible: text.length > 1
            }

            Text {
                text: `Last checked: ${Qt.formatDateTime(Services.ServerStatus.lastChecked, "hh : mm")}`
                color: "#bfbfbf"
                font.pixelSize: 12
                visible: Services.ServerStatus.serverLatency >= 0
            }
        }
    }
}