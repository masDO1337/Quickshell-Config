import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property bool showIcon: true
    property url source: ""
    property int iconSize: 14
    
    property bool showText: false
    property string text: ""
    property string textColor: "white"

    property alias rowLayout: row
    
    property alias mouse: m
    property var acceptedButtons: Qt.LeftButton
    property var onClicked: (event) => {}
    property var onWheel: (event) => {}

    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight + 8
    radius: 6
    color: m.containsMouse ? '#707f7f7f' : "transparent"

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        IconImage {
            implicitSize: root.iconSize
            source: root.source
            visible: root.showIcon
        }

        Text {
            text: root.text
            color: root.textColor
            font.pixelSize: 13
            font.bold: true
            visible: root.showText
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