pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import "UI" as UI

Tooltip {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering

    readonly property string status: {
        if (!available)
            return "No Bluetooth adapter"

        if (!enabled)
            return "Bluetooth off"

        if (discovering)
            return "Scanning..."

        return adapter.name
    }

    Item {
        anchors.fill: parent
        implicitWidth: Math.max(380, column.implicitWidth)
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.status
                        color: "#808080"
                        font.pixelSize: 12
                    }
                }

                UI.Toggle {
                    acceptedButtons: Qt.LeftButton
                    onClicked: () => root.adapter.enabled = !root.adapter.enabled
                    checked: root.enabled
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
                visible: root.enabled
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                visible: root.enabled

                Text {
                    Layout.fillWidth: true
                    text: "Devices"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                UI.Button {
                    text: root.adapter.discovering ? "Stop" : "Scan"
                    textSize: 12

                    onClicked: () => root.adapter.discovering = !root.adapter.discovering
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.topMargin: 0
                implicitHeight: Math.min(contentHeight, 260)
                clip: true

                visible: root.enabled && count !== 0

                model: root.adapter.devices

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
                    required property BluetoothDevice modelData

                    width: ListView.view.width
                    implicitHeight: 42
                    radius: 6

                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: () => node.modelData.connected = !node.modelData.connected
                        onPositionChanged: list.currentIndex = node.index
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Item {
                            width: 28
                            height: 28
                            Layout.alignment: Qt.AlignVCenter
                            visible: Quickshell.iconPath(node.modelData?.icon ?? "", true) !== ""

                            IconImage {
                                anchors.fill: parent
                                implicitSize: 28
                                source: Quickshell.iconPath(node.modelData?.icon ?? "", true)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: node.modelData?.name || node.modelData?.deviceName || node.modelData?.address || "Unknown"
                                color: node.modelData?.connected ?? false
                                    ? "#a6f3b0"
                                    : list.currentIndex === node.index 
                                    ? "white"
                                    : "#808080"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            Text {
                                text: BluetoothDeviceState.toString(node.modelData?.state ?? BluetoothDeviceState.Disconnected)
                                color: "#808080"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        // Battery indicator
                        Item {
                            implicitWidth: batteryRow.implicitWidth
                            visible: node.modelData?.batteryAvailable ?? false
                            RowLayout {
                                id: batteryRow
                                anchors.centerIn: parent
                                spacing: 4

                                IconImage {
                                    implicitSize: 16
                                    source: {
                                        if (node.modelData?.battery < 0.3)
                                            return Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-empty.svg"))
                                        else if (node.modelData?.battery < 0.6)
                                            return Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-half.svg"))
                                        else
                                            return Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-full.svg"))
                                    }
                                }

                                Text {
                                    text: Math.round(node.modelData?.battery * 100) + "%"
                                    color: "#bfbfbf"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        UI.Button {
                            text: node.modelData?.trusted ? "Untrust" : "Trust"
                            textSize: 12
                            visible: node.modelData?.paired ?? false

                            onClicked: () => node.modelData.trusted = !node.modelData.trusted
                        }

                        UI.Button {
                            source: Qt.resolvedUrl(Quickshell.shellPath("Icons/trash.svg"))
                            visible: node.modelData?.paired ?? false

                            onClicked: () => node.modelData.forget()
                        }

                        UI.Button {
                            text: "Pair"
                            textSize: 12
                            textBold: true
                            visible: !node.modelData?.paired ?? false

                            onClicked: () => node.modelData.pair()
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.topMargin: 0
                horizontalAlignment: Text.AlignHCenter
                visible: root.enabled && list.count === 0
                text: "No devices found"
                color: "#888"
                font.pixelSize: 12
            }
        }
    }
}