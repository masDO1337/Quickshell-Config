import QtQuick

Rectangle {
    id: root

    property bool checked: false

    property alias mouse: m
    property var acceptedButtons: Qt.LeftButton
    property var onClicked: (event) => {}

    implicitWidth: 60
    implicitHeight: 32
    radius: 16
    color: m.containsMouse ? '#7f7f7f' : "#1e1e1e"

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 8
        implicitWidth: 16
        implicitHeight: 16
        x: root.checked ? root.width - width - 8 : 8
        Behavior on x {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
        radius: 14
        color: root.checked ? "#FFF" : m.containsMouse ? "#1e1e1e" : "#808080"
    }

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: root.acceptedButtons
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => root.onClicked(event)
    }
}