import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: root
    property var onClicked: undefined

    Layout.preferredWidth: 32
    Layout.preferredHeight: 32
    radius: 16
    color: closeHover.containsMouse ? '#7f7f7f' : '#1e1e1e'

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }
    
    IconImage {
        id: image
        implicitSize: 16
        anchors.centerIn: parent
        source: Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg"))
    }

    MouseArea {
        id: closeHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: () => root.onClicked()
    }
}