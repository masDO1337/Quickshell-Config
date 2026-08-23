import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../services" as Services
import "UI" as UI

Tooltip {
    Item {
        id: root
        implicitWidth: Math.max(320, mainColumn.implicitWidth)
        implicitHeight: mainColumn.implicitHeight

        property var mc: Services.ServerStatus.mc

        ColumnLayout {
            id: mainColumn
            anchors.fill: parent
            spacing: 0
            
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

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
                            Layout.fillWidth: true
                            text: `${Services.ServerStatus.host ?? ""}:${Services.ServerStatus.port ?? ""}`
                            color: "#808080"
                            font.pixelSize: 12
                        }
                    }

                    Text {
                        text: `${Services.ServerStatus.status}`
                        color: "#808080"
                        font.pixelSize: 12
                    }
                }

                UI.Button {
                    showIcon: false
                    showText: true
                    text: "IP"
                    textSize: 12

                    onClicked: () => Services.ServerStatus.setIP()
                }

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/refresh.svg"))
                    iconSize: 16
                    onClicked: () => Services.ServerStatus.check()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6

                Text {
                    text: `${root.mc.error ?? ""}`
                    color: 'white'
                    font.pixelSize: 12
                    visible: text.length > 0
                }

                RowLayout {
                    Layout.bottomMargin: 10
                    spacing: 5
                    visible: (root.mc.icon ?? false) || (root.mc.motd ?? false)

                    Item {
                        visible: root.mc.icon ?? false
                        implicitWidth: sourceImage.width
                        implicitHeight: sourceImage.height

                        IconImage {
                            id: sourceImage
                            implicitSize: 64
                            source: root.mc.icon ?? ""
                            visible: false
                        }

                        MultiEffect {
                            anchors.fill: sourceImage
                            source: sourceImage

                            maskEnabled: true
                            maskSource: mask
                        }

                        Item {
                            id: mask
                            width: sourceImage.width
                            height: sourceImage.height
                            layer.enabled: true
                            visible: false

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 5
                        text: `${root.mc.motd ?? ""}`
                        color: 'white'
                        font.pixelSize: 14
                        font.bold: true
                        visible: text.length > 0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.mc.players ?? false

                    Text {
                        text: `Players: `
                        color: 'white'
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: `${root.mc.players?.online ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }

                    Text {
                        text: `/`
                        color: "#808080"
                        font.pixelSize: 12
                    }

                    Text {
                        text: `${root.mc.players?.max ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.mc.channels ?? false

                    Text {
                        text: `Channels: `
                        color: 'white'
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: `${root.mc.channels ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.mc.mods ?? false

                    Text {
                        text: `Mods: `
                        color: 'white'
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: `${root.mc.mods ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.mc.version ?? false

                    Text {
                        text: `Version: `
                        color: 'white'
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: `${root.mc.version?.type ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }

                    Text {
                        text: `${root.mc.version?.name ?? ""}`
                        color: 'white'
                        font.pixelSize: 12
                    }
                }

                Text {
                    text: `Last checked: ${Qt.formatDateTime(Services.ServerStatus.lastChecked, "hh : mm")}`
                    color: "#808080"
                    font.pixelSize: 12
                }

                Text {
                    text: `Lateney: ${Services.ServerStatus.latency} ms`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: Services.ServerStatus.latency >= 0
                }
            }
        }
    }
}