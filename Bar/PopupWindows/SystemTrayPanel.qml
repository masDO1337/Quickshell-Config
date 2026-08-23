pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "UI" as UI

Tooltip {
    id: root

    property var data: null

    Item {
        anchors.fill: parent
        implicitWidth: Math.max(260, column.implicitWidth)
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 10

                IconImage {
                    implicitSize: 32
                    source: root.data.icon
                    visible: root.data.icon != ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    
                    Text {
                        Layout.fillWidth: true
                        text: root.data.title || root.data.tooltipTitle
                        color: "#fff"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.data.tooltipDescription || root.data.id
                        color: "#afafaf"
                        font.pixelSize: 12
                    }
                }

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg"))
                    iconSize: 16
                    onClicked: event => {
                        if (event.button == Qt.LeftButton) {
                            root.toggle();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            Repeater {
                property QsMenuOpener menuList: QsMenuOpener {
                    menu: root.data.menu
                }
                
                model: menuList.children

                Rectangle {
                    id: item
                    required property QsMenuEntry modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: modelData.isSeparator ? 1 : row.implicitHeight + 16
                    color: modelData.isSeparator ? '#afafaf' : m.containsMouse ? '#707f7f7f' : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        id: row
                        anchors.fill: parent
                        anchors.margins: 8
                        anchors.leftMargin: 12
                        spacing: 4
                        visible: !item.modelData.isSeparator

                        IconImage {
                            implicitSize: 16
                            source: item.modelData.icon || Qt.resolvedUrl(Quickshell.shellPath("Icons/dot-circle.svg"))
                        }

                        Text {
                            Layout.fillWidth: true
                            text: item.modelData.text
                            color: "#fff"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: m
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: event => {
                            if (event.button == Qt.LeftButton) {
                                item.modelData.triggered();
                                root.toggle();
                            }
                        }
                    }
                }
            }
        }
    }
}