pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../PopupWindows"
import "UI" as UI

Repeater {
    model: SystemTray.items

    Item {
        id: node
        required property SystemTrayItem modelData

        Layout.fillHeight: true
        implicitWidth: box.implicitWidth

        UI.Button {
            id: box
            anchors.centerIn: parent

            source: Qt.resolvedUrl(node.modelData.icon)

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

        SystemTrayPanel {
            id: menu
            parentItem: node
            data: node.modelData
        }
    }
}