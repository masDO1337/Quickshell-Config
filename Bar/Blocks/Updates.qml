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

        source: Services.Updates.showPackages ? Qt.resolvedUrl(Quickshell.shellPath("Icons/update.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/up-to-date.svg"))

        text: Services.Updates.checking ? "Checking" : Services.Updates.showPackages ? Services.Updates.packages.count.toString() : ""
        textColor: "#f3a6a6"

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (event) => {
            if (event.button == Qt.LeftButton) {
                updatePanel.toggle()
            } 
            if (event.button == Qt.RightButton) {
                Services.Updates.checkAllUpdates()
            }
        }
    }

    UpdatesPanel {
        id: updatePanel
        parentItem: root
    }
}