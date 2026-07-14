pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services" as Services
import "UI" as UI

Tooltip {
    Item {
        anchors.fill: parent
        implicitWidth: Math.max(mainColumn.implicitWidth, 360)
        implicitHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            anchors.fill: parent
            spacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "WiFi"
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    UI.Button {
                        showIcon: false
                        showText: true
                        text: Services.Iwd.powered ? "Turn off" : "Turn on"
                        textSize: 12

                        onClicked: () => Services.Iwd.setPowered(!Services.Iwd.powered)
                        visible: Services.Iwd.deviceFound
                    }

                    UI.Button {
                        showIcon: false
                        showText: true
                        text: "Refresh"
                        textSize: 12

                        onClicked: () => Services.Iwd.refresh()
                        visible: Services.Iwd.deviceFound
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Services.Iwd.statusText
                    color: "#808080"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: "#1e1e1e"
                visible: Services.Iwd.deviceFound
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                visible: Services.Iwd.deviceFound

                Text {
                    Layout.fillWidth: true
                    text: "Networks"
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                }

                UI.Button {
                    showIcon: false
                    showText: true
                    text: "Scan"
                    textSize: 12

                    onClicked: () => Services.Iwd.scan()
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.margins: 10
                implicitHeight: Math.min(contentHeight, 260)
                clip: true

                visible: Services.Iwd.deviceFound

                model: Services.Iwd.networks

                highlight: Rectangle {
                    radius: 8
                    color: '#1e1e1e'
                    visible: list.currentIndex >= 0

                    Rectangle {
                        width: 3
                        height: 24
                        radius: 2
                        color: "#808080"
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                delegate: Rectangle {
                    id: node
                    required property var index
                    required property var modelData

                    width: ListView.view.width
                    implicitHeight: 42
                    radius: 6

                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Iwd.connect(node.modelData.ssid)
                        onPositionChanged: list.currentIndex = node.index
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: node.modelData.ssid
                                color: node.modelData.ssid === Services.Iwd.connectedNetwork
                                    ? "#a6f3b0"
                                    : "white"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: node.modelData.security
                                color: "#808080"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        UI.Button {
                            source: Qt.resolvedUrl(Quickshell.shellPath("Icons/trash.svg"))
                            visible: Services.Iwd.isKnown(node.modelData.ssid)

                            onClicked: () => Services.Iwd.remove(node.modelData.ssid)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: Services.Iwd.powered
                        ? "No networks found"
                        : "WiFi is turned off"
                    color: "#888"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 10
                implicitHeight: 32
                radius: 6
                color: disconnectMouse.containsMouse ? "#7f4f4f" : "#5a3535"
                visible: Services.Iwd.connected && Services.Iwd.deviceFound

                Text {
                    anchors.centerIn: parent
                    text: "Disconnect from " + Services.Iwd.connectedNetwork
                    color: "white"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: disconnectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Iwd.disconnect()
                }
            }
        }
    }
}