import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property int index: 0
    property int currentIndex: 0
    property bool on: mouse.containsMouse || index === currentIndex
    property string text: "Button"
    property url source: undefined
    property var onClicked: () => {}
    property var onEntered: (index) => {}

    Layout.fillWidth: !on
    implicitWidth: row.implicitWidth + 13
    implicitHeight: row.implicitHeight + 13
    radius: 8
    color: on ? '#487f7f7f' : '#48080808'

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        IconImage {
            implicitSize: 32
            source: root.source
        }

        Text {
            text: root.text
            color: "#fff"
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
            visible: root.on
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.onClicked()
        onEntered: root.onEntered(root.index)
    }
}