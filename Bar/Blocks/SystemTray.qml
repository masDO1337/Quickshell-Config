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
            iconSize: 16

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: event => {
                if (event.button == Qt.LeftButton) {
                    menuAnchor.open();
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

        QsMenuAnchor {
            id: menuAnchor
            menu: node.modelData.menu

            anchor.window: node.QsWindow.window
            anchor.adjustment: PopupAdjustment.Flip

            anchor.onAnchoring: {
                const window = node.QsWindow.window;
                const widgetRect = window.contentItem.mapFromItem(node, 0, node.height, node.width, node.height);

                menuAnchor.anchor.rect = widgetRect;
            }
        }

        Tooltip {
            parentItem: node

            hover: box.mouse.containsMouse

            Item {
                anchors.fill: parent
                implicitWidth: t.implicitWidth + 20
                implicitHeight: t.implicitHeight + 20

                Text {
                    id: t
                    anchors.centerIn: parent
                    
                    text: modelData.title || modelData.id
                    color: "#fff"
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
}