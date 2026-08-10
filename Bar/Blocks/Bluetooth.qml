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
    visible: Bluetooth.defaultAdapter

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Bluetooth.defaultAdapter?.enabled ? Qt.resolvedUrl(Quickshell.shellPath("Icons/bluetooth.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/bluetooth-off.svg"))

        onClicked: () => panel.toggle()
    }

    BluetoothPanel {
        id: panel
        parentItem: root
    }
}