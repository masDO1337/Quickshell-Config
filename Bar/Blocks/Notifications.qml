import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services" as Services
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth

    signal toggle()

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Services.Notifications.history.count === 0 ? Qt.resolvedUrl(Quickshell.shellPath("Icons/notification-none.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/notification-on.svg"))

        onClicked: () => root.toggle()
    }
}