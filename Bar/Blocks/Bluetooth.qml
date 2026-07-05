import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../PopupWindows"
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth

    signal toggle()

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Qt.resolvedUrl(Quickshell.shellPath("Icons/bluetooth.svg"))

        onClicked: () => root.toggle()
    }

    Tooltip {
        id: tooltip
        parentItem: root
        hover: box.mouse.containsMouse

        Text {
            text: Bluetooth.defaultAdapter.dbusPath ?? "none"
            color: "white"
        }
    }
}