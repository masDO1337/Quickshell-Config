pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "UI" as UI

Tooltip {
    id: root
    Item {
        anchors.fill: parent

        implicitWidth: Math.max(column.implicitWidth, 400)
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 0

            RowLayout {
                id: row
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                spacing: 20

                RowLayout {
                    spacing: 10
                    
                    Text {
                        text: "Pacman"
                        color:"#828282"
                        font.pixelSize: 14
                    }

                    Text {
                        text: Services.Updates.packagesPacman
                        color: update.mouse.containsMouse ? "#fff" : "#828282"
                        font.pixelSize: 14
                    }
                }

                RowLayout {
                    spacing: 10

                    Text {
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

                Item { 
                    Layout.fillWidth: true
                    visible: Services.Updates.showUpdates
                }

                UI.Button {
                    id: update
                    Layout.alignment: Qt.AlignRight
                    visible: Services.Updates.showUpdates

                    showIcon: false
                    showText: true
                    text: "Update All"
                    textSize: 14

                    onClicked: () => {
                        Services.Updates.runUpdate("")
                        root.toggle()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            ListView {  
                id: resultsList

                visible: Services.Updates.showUpdates

                model: Services.Updates.packages

                Layout.fillWidth: true
                Layout.margins: 10
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

                    Rectangle {
                        width: 3
                        height: 16
                        radius: 2
                        color: "#808080"
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    required property var modelData
                    required property int index
                    property string from: modelData.from

                    width: resultsList.width
                    height: 30
                    radius: 6
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 0

                        RowLayout {
                            Layout.preferredWidth: 180
                            spacing: 2

                            Text {
                                text: delegateRoot.from !== "pacman" ? `[${delegateRoot.from.toUpperCase()}]` : ""
                                color: resultsList.currentIndex === delegateRoot.index ? "white" : "#828282"
                                font.pixelSize: 12
                                visible: text !== ""
                            }

                            Text {
                                text: delegateRoot.modelData.name
                                color: resultsList.currentIndex === delegateRoot.index ? "white" : "#828282"
                                font.pixelSize: 12
                                font.bold: resultsList.currentIndex === delegateRoot.index
                                elide: Text.ElideRight
                            }
                        }
  
                        Text {
                            Layout.preferredWidth: 80
                            text: delegateRoot.modelData.old
                            color: resultsList.currentIndex === delegateRoot.index ? "#f3a6a6" : "#828282"
                            font.pixelSize: 12
                            elide: Text.ElideLeft
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: delegateRoot.modelData.new
                            color: resultsList.currentIndex === delegateRoot.index ? '#bcf3a6' : "#828282"
                            font.pixelSize: 12
                            elide: Text.ElideLeft
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: () => {
                            Services.Updates.runUpdate(delegateRoot.modelData.name)
                            root.toggle()
                        }
                        onPositionChanged: resultsList.currentIndex = delegateRoot.index
                    }

                }
            }

            Text {
                Layout.margins: 10
                Layout.alignment: Qt.AlignHCenter
                text: "No package found"
                color: '#828282'
                font.pixelSize: 16
                visible: resultsList.count === 0
            }
        }
    }
}