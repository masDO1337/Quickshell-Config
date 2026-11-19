import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "UI" as UI

Tooltip {
    id: root

    property int index
    property var modelData

    Item {
        implicitWidth: Math.max(320, mainColumn.implicitWidth)
        implicitHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "IP:"
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: `${root.modelData.host ?? ""}:${root.modelData.port ?? ""}`
                            color: "#808080"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Status:"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.modelData.serverOn ? "Online" : "Offline"
                            color: root.modelData.serverOn ? "#ffffff" : "#808080"
                            font.pixelSize: 12
                        }
                    }
                }

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/refresh.svg"))
                    iconSize: 16
                    onClicked: () => Services.ServerStatus.check(root.index, true)
                }

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/trash.svg"))
                    iconSize: 16
                    onClicked: () => Services.ServerStatus.removeServer(root.index)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
                visible: root.modelData.mc.online || (root.modelData.mc?.error ?? false)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 20
                visible: root.modelData.mc.online || (root.modelData.mc?.error ?? false)

                Text {
                    text: `${root.modelData.mc?.error ?? ""}`
                    color: 'white'
                    font.pixelSize: 12
                    visible: text.length > 0
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.modelData.mc.online ?? false
                    spacing: 12

                    ClippingRectangle {
                        visible: root.modelData.mc.icon ?? false
                        Layout.preferredWidth: sourceImage.width
                        Layout.preferredHeight: sourceImage.height
                        radius: 6

                        IconImage {
                            id: sourceImage
                            implicitSize: 64
                            source: root.modelData.mc.icon ?? ""
                            visible: source !== ""
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: `${root.modelData.mc.motd ?? "MInecraft server"}`
                            color: 'white'
                            font.pixelSize: 14
                            font.bold: true
                            visible: text.length > 0
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            RowLayout {
                                visible: root.modelData.mc.version ?? false
                                spacing: 4

                                Text {
                                    text: `${root.modelData.mc.version?.type ?? ""}`
                                    color: 'white'
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: `${root.modelData.mc.version?.name ?? ""}`
                                    color: 'white'
                                    font.pixelSize: 12
                                }
                            }

                            RowLayout {
                                visible: root.modelData.mc.mods ?? false
                                spacing: 0

                                Text {
                                    text: `Mods: `
                                    color: '#808080'
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text {
                                    text: `${root.modelData.mc.mods ?? ""}`
                                    color: 'white'
                                    font.pixelSize: 12
                                }
                            }

                            RowLayout {
                                visible: root.modelData.mc.channels ?? false
                                spacing: 0

                                Text {
                                    text: `Ch: `
                                    color: '#808080'
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text {
                                    text: `${root.modelData.mc.channels ?? ""}`
                                    color: 'white'
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.modelData.mc.players?.sample?.length > 0

                    Text {
                        text: `Players: `
                        color: '#808080'
                        font.pixelSize: 12
                        font.bold: true
                    }
                    
                    Repeater {
                        model: root.modelData.mc.players?.sample ?? []

                        Rectangle {
                            id: playerRect
                            required property var modelData
                            Layout.preferredWidth: playerName.implicitWidth + 8
                            Layout.preferredHeight: playerName.implicitHeight + 4
                            color: '#1E1E1E'
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                id: playerName
                                text: `${playerRect.modelData.name ?? ""}`
                                color: 'white'
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 6

                Text {
                    text: `Last checked: ${Qt.formatDateTime(root.modelData.lastChecked, "hh : mm")}`
                    color: "#808080"
                    font.pixelSize: 12
                }

                Text {
                    text: `Lateney: ${root.modelData.latency} ms`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: root.modelData.latency >= 0
                }
            }
        }
    }
}