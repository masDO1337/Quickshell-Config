import QtQuick
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: root
    
    property string text: ""
    property var onClicked: undefined
    
    width: (root.text === "" ? image.width : mainText.width) + 12
    height: (root.text === "" ? image.height : mainText.height) + 12
    radius: 10
    color: closeHover.containsMouse ? '#487f7f7f' : '#1e1e1e'

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }
    
    IconImage {
        id: image
        implicitSize: 16
        anchors.centerIn: parent
        source: Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg"))
        visible: root.text === ""
    }

    Text {
        id: mainText
        anchors.centerIn: parent
        text: root.text
        color: "#fff"
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