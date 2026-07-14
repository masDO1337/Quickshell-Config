pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "UI" as UI

Tooltip {
    id: root
    
    property var onClicked: (name) => {
        Services.Updates.runUpdate(name)
        toggle()
    }

    Item {
        anchors.fill: parent

        implicitWidth: column.implicitWidth
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.centerIn: parent
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
                        font.pixelSize: 16
                    }

                    Text {
                        text: Services.Updates.packagesPacman
                        color: update.mouse.containsMouse ? "#fff" : "#828282"
                        font.pixelSize: 16
                    }
                }

                RowLayout {
                    spacing: 10

                    Text {
                        text: "AUR"
                        color: "#828282"
                        font.pixelSize: 16
                    }

                    Text {
                        text: Services.Updates.packagesAUR
                        color: update.mouse.containsMouse ? "#fff" : "#828282"
                        font.pixelSize: 16
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

                    onClicked: () => root.onClicked("")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: '#1e1e1e'
            }

            ListView {  
                id: resultsList

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

                    width: resultsList.width
                    height: 25
                    radius: 6
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 0

                        RowLayout {
                            Layout.preferredWidth: 160
                            Layout.maximumWidth: 160
                            spacing: 2

                            Text {
                                Layout.maximumWidth: 155
                                text: delegateRoot.modelData.name
                                color: resultsList.currentIndex === delegateRoot.index ? "white" : "#828282"
                                font.pixelSize: 12
                                font.bold: resultsList.currentIndex === delegateRoot.index
                                elide: Text.ElideRight
                            }

                            Text {
                                text: delegateRoot.modelData.from !== "pacman" ? `(${delegateRoot.modelData.from})` : ""
                                color: "#828282"
                                font.pixelSize: 12
                                visible: text !== ""
                            }
                            Item { Layout.fillWidth: true }
                        }

                        Item {
                            Layout.fillWidth: true    
                            Text {
                                text: delegateRoot.modelData.old
                                color: resultsList.currentIndex === delegateRoot.index ? "#f3a6a6" : "#828282"
                                font.pixelSize: 12
                                anchors.centerIn: parent
                                elide: Text.ElideRight
                            }
                        }
                        Item{
                            Layout.fillWidth: true
                            Text {
                                text: delegateRoot.modelData.new
                                color: resultsList.currentIndex === delegateRoot.index ? '#bcf3a6' : "#828282"
                                font.pixelSize: 12
                                anchors.centerIn: parent
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.onClicked(delegateRoot.modelData.name)
                        onPositionChanged: resultsList.currentIndex = delegateRoot.index
                    }

                }

                Text {
                    anchors.centerIn: parent
                    text: "No package found"
                    color: '#828282'
                    font.pixelSize: 16
                    visible: resultsList.count === 0
                }
            }
        }
    }
}