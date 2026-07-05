import QtQuick
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: root
    
    property string text: ""
    property var onClicked: undefined
    
    width: (root.text === "" ? image.width : mainText.width) + 6
    height: (root.text === "" ? image.height : mainText.height) + 6
    radius: 10
    color: closeHover.containsMouse ? '#1e1e1e' : "transparent"
    
    IconImage {
        id: image
        implicitSize: 16
        anchors.centerIn: parent
        source: closeHover.containsMouse ? Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/x-2.svg"))
        visible: root.text === ""
    }

    Text {
        id: mainText
        anchors.centerIn: parent
        text: root.text
        color: closeHover.containsMouse ? "#fff" : "#828282"
        font.pixelSize: 16
        visible: root.text !== ""
    }

    MouseArea {
        id: closeHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.onClicked()
    }
}