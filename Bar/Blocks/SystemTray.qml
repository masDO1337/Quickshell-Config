pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../PopupWindows"

Repeater {
    model: SystemTray.items

    Item {
        id: node
        required property SystemTrayItem modelData

        Layout.fillHeight: true
        implicitWidth: box.implicitWidth

        Rectangle {
            id: box
            anchors.centerIn: parent

            implicitWidth: 22
            implicitHeight: 22
            radius: 4
            color: m.containsMouse ? '#7f7f7f' : "transparent"

            Behavior on color {
                ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 14
                source: Qt.resolvedUrl(node.modelData.icon)
            }

            MouseArea {
                id: m
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    if (event.button == Qt.LeftButton) {
                        menu.toggle();
                    } else if (event.button == Qt.MiddleButton) {
                        node.modelData.secondaryActivate();
                    } else if (event.button == Qt.RightButton) {
                        node.modelData.activate();
                    }
                }
                onWheel: event => {
                    event.accepted = true;
                    const points = event.angleDelta.y / 120
                    node.modelData.scroll(points, false);
                }
            }
        }

        SystemTrayPanel {
            id: menu
            parentItem: node
            data: node.modelData
        }
    }
}