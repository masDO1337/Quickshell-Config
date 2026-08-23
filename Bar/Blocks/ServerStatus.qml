import Quickshell
import QtQuick
import QtQuick.Layouts
import "../PopupWindows"
import "../../services" as Services
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    implicitWidth: box.implicitWidth

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Services.ServerStatus.serverOn ? Qt.resolvedUrl(Quickshell.shellPath("Icons/server-white.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/server.svg"))

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (event) => {
            if (event.button == Qt.LeftButton) {
                serverStatus.toggle()
            } else if (event.button == Qt.RightButton) {
                Services.ServerStatus.check()
            }
        }
    }
    
    ServerStatusPanel {
        id: serverStatus
        parentItem: root
    }
}