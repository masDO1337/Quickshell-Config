import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services" as Services
import "../PopupWindows"
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth
    visible: Services.Bluetooth.available

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Qt.resolvedUrl(Quickshell.shellPath("Icons/bluetooth.svg"))

        onClicked: () => panel.toggle()
    }

    BluetoothPanel {
        id: panel
        parentItem: root
    }
}