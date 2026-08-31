pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../../services" as Services
import "UI" as UI

Tooltip {
    Item {
        anchors.fill: parent
        implicitWidth: Math.max(460, column.implicitWidth)
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

                ColumnLayout {

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#fff"
                    }

                    Text {
                        Layout.fillWidth: true
                        text: `History ${Services.Notifications.historyLength}`
                        color: "#828282"
                        font.pixelSize: 14
                    }
                }

                UI.Button {
                    text: "Ctear all"
                    onClicked: () => Services.Notifications.clear()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.preferredHeight: 350

                model: Services.Notifications.history

                clip: true
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 150
                highlightMoveVelocity: -1

                currentIndex: -1

                highlight: Rectangle {
                    color: '#1e1e1e'
                    visible: resultsList.currentIndex >= 0
                }

                delegate: Rectangle {
                    id: node
                    required property var modelData
                    required property int index

                    property string urgencyColor: modelData.urgency === NotificationUrgency.Critical ? "#f3a6a6" : modelData.urgency === NotificationUrgency.Normal ? "#afafaf" : '#1c1c1c'
                    property date date: new Date(modelData.time)

                    property bool hover: resultsList.currentIndex === node.index

                    width: resultsList.width
                    implicitHeight: content.implicitHeight + 20
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: resultsList.currentIndex = node.index
                    }
                    
                    ColumnLayout {
                        id: content
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Item {
                                Layout.preferredWidth: image.implicitSize
                                Layout.preferredHeight: image.implicitSize

                                ClippingRectangle {
                                    anchors.fill: parent
                                    radius: 32
                                    color: "transparent"

                                    IconImage {
                                        id: image
                                        anchors.centerIn: parent
                                        implicitSize: (node.modelData.image ?? "") !== "" ? 64 : 48
                                        source: {
                                            const isImage = (node.modelData.image ?? "") !== ""
                                            const src = Quickshell.iconPath(node.modelData.appIcon ?? "", true)
                                            return isImage ? node.modelData.image : src !== "" ? src : node.modelData.appIcon
                                        }
                                    }
                                }
                            }

                            ColumnLayout {

                                Text {
                                    Layout.fillWidth: true
                                    text: node.modelData.summary ?? ""
                                    color: node.hover ? "#fff" : "#828282"
                                    font.pixelSize: 16
                                    font.bold: node.hover
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: node.modelData.body ?? ""
                                    color: "#828282"
                                    font.pixelSize: 16
                                    elide: node.hover ? Text.ElideNone : Text.ElideRight
                                    wrapMode: node.hover ? Text.Wrap : Text.NoWrap
                                    maximumLineCount: node.hover ? 99 : 1
                                    visible: text !== ""
                                }
                            }

                            UI.Button {
                                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg"))
                                onClicked: () => Services.Notifications.remove(node.index)
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: `${Qt.formatDateTime(node.date, "yyyy-MM-dd  HH:mm")}` ?? ""
                            color: "#828282"
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "No notifications found"
                    color: '#828282'
                    font.pixelSize: 16
                    visible: resultsList.count === 0
                }
            }
        }
    }
}