pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "UI" as UI

Tooltip {
    id: root
    Item {
        anchors.fill: parent

        implicitWidth: Services.Updates.showPackages ? 400 : column.implicitWidth
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            RowLayout {
                id: row
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 20
                Layout.fillWidth: true
                spacing: 6

                visible: Services.Updates.showPackages

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    
                    Text {
                        Layout.alignment: Qt.AlignRight
                        text: "Pacman"
                        color:"#828282"
                        font.pixelSize: 14
                    }

                    Text {
                        text: Services.Updates.packagesPacman
                        color: update.mouse.containsMouse ? "#fff" : "#828282"
                        font.pixelSize: 14
                    }

                    Text {
                        Layout.alignment: Qt.AlignRight
                        text: "AUR"
                        color: "#828282"
                        font.pixelSize: 14
                    }

                    Text {
                        text: Services.Updates.packagesAUR
                        color: update.mouse.containsMouse ? "#fff" : "#828282"
                        font.pixelSize: 14
                    }
                }

                Item { Layout.fillWidth: true }

                UI.Button {
                    visible: Services.Updates.showUpdates
                    text: "Clear"
                    onClicked: () => Services.Updates.clearUpdate()
                }

                UI.Button {
                    visible: Services.Updates.showUpdates
                    text: "Update"
                    onClicked: () => {
                        Services.Updates.runUpdate(false)
                        root.toggle()
                    }
                }

                UI.Button {
                    id: update
                    text: "Update All"
                    onClicked: () => {
                        Services.Updates.runUpdate(true)
                        root.toggle()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
                visible: Services.Updates.showPackages
            }

            ListView {  
                id: resultsList

                visible: Services.Updates.showPackages

                model: Services.Updates.packages

                Layout.fillWidth: true
                Layout.margins: 20
                implicitHeight: Math.min(contentHeight, 600)

                clip: true
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 150
                highlightMoveVelocity: -1

                highlight: Rectangle {
                    radius: 8
                    color: '#1e1e1e'
                    visible: resultsList.currentIndex >= 0
                }

                delegate: Rectangle {
                    id: node
                    required property var modelData
                    required property int index
                    property string name: modelData.name
                    property string from: modelData.from

                    width: resultsList.width
                    height: 30
                    radius: 6
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            Layout.leftMargin: 8
                            radius: 4
                            color: Services.Updates.isInUpdates(node.name) ? "#fff" : resultsList.currentIndex === node.index ? "#7f7f7f" : "#1e1e1e"
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: `${node.from !== "pacman" ? node.from.toUpperCase() + "  " : ""}${node.name}`
                            color: resultsList.currentIndex === node.index ? "white" : "#7f7f7f"
                            font.pixelSize: 12
                            font.bold: resultsList.currentIndex === node.index
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: node.modelData.old
                            color: resultsList.currentIndex === node.index ? "#f3a6a6" : "#7f7f7f"
                            font.pixelSize: 12
                            elide: Text.ElideLeft
                        }

                        Text {
                            text: ">"
                            color: resultsList.currentIndex === node.index ? "#fff" : "#7f7f7f"
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: node.modelData.new
                            color: resultsList.currentIndex === node.index ? '#bcf3a6' : "#7f7f7f"
                            font.pixelSize: 12
                            elide: Text.ElideLeft
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: () => Services.Updates.toUpdate(node.name)
                        onEntered: resultsList.currentIndex = node.index
                    }

                }
            }

            Text {
                Layout.margins: 20
                Layout.alignment: Qt.AlignHCenter
                text: "No package found"
                color: '#828282'
                font.pixelSize: 16
                visible: resultsList.count === 0
            }
        }
    }
}