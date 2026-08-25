import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property url source: ""
    
    property string text: ""
    property string textColor: "white"

    property alias mouse: m
    property var acceptedButtons: Qt.LeftButton
    property var onClicked: (event) => {}
    property var onWheel: (event) => {}

    implicitWidth: row.implicitWidth + 8
    implicitHeight: 22
    radius: 4
    color: m.containsMouse ? '#707f7f7f' : "transparent"

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        IconImage {
            implicitSize: 14
            source: root.source
        }

        Text {
            text: root.text
            color: root.textColor
            font.pixelSize: 13
            font.bold: true
            visible: root.text.length > 0
        }
    }

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: root.acceptedButtons
        onClicked: event => root.onClicked(event)
        onWheel: event => root.onWheel(event)
    }
}