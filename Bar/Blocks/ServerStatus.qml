import Quickshell
import QtQuick
import QtQuick.Layouts
import "../PopupWindows"
import "../../services" as Services
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    Layout.preferredWidth: row.implicitWidth

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: Services.ServerStatus.servers

            Item {
                id: serverItem
                
                required property int index
                required property var modelData

                Layout.fillHeight: true
                Layout.preferredWidth: serverButton.implicitWidth

                UI.Button {
                    id: serverButton
                    anchors.centerIn: parent

                    source: serverItem.modelData.mc.online ? Qt.resolvedUrl(Quickshell.shellPath("Icons/server-green.svg")) : serverItem.modelData.serverOn ? Qt.resolvedUrl(Quickshell.shellPath("Icons/server-white.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/server.svg"))

                    text: serverItem.modelData.mc.online ? `${serverItem.modelData.mc.players.online} / ${serverItem.modelData.mc.players.max}` : ""

                    textColor: "#AEF3A6"

                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    onClicked: (event) => {
                        if (event.button == Qt.LeftButton) {
                            serverStatus.toggle()
                        } else if (event.button == Qt.RightButton) {
                            Services.ServerStatus.check(serverItem.index, true)
                        } else if (event.button == Qt.MiddleButton) {
                            Services.ServerStatus.addServer()
                        }
                    }
                }

                ServerStatusPanel {
                    id: serverStatus
                    parentItem: serverItem
                    index: serverItem.index
                    modelData: serverItem.modelData
                }
            }
        }

        UI.Button {
            id: add
            visible: Services.ServerStatus.servers.length == 0

            source: add.mouse.containsMouse ? Qt.resolvedUrl(Quickshell.shellPath("Icons/plus-white.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/plus.svg"))

            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (event) => {
                if (event.button == Qt.LeftButton) {
                    Services.ServerStatus.addServer()
                } else if (event.button == Qt.RightButton) {
                    Services.ServerStatus.check()
                }
            }
        }
    }
}