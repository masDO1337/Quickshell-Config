import QtQuick
import QtQuick.Layouts
import Quickshell
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth
    
    signal toggle()

    UI.Button {
        id: box
        anchors.centerIn: parent
        source: Qt.resolvedUrl(Quickshell.shellPath("Icons/aperture.svg"))
        onClicked: () => root.toggle()
    }
}