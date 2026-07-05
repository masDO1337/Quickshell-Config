import QtQuick

Rectangle {
    id: root
    
    property string text: "Button"
    property var onClicked: () => {}

    implicitWidth: t.implicitWidth + 14
    implicitHeight: t.implicitHeight + 14
    radius: 8
    color: mouse.containsMouse && root.enabled ? '#487f7f7f' : '#00ffffff'

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    Text {
        id: t
        text: root.text
        anchors.centerIn: parent
        color: mouse.containsMouse && root.enabled ? "#fff" : "#828282"
        font.pixelSize: 16
        font.bold: true
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouse
        enabled: root.enabled
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.onClicked()
    }
}