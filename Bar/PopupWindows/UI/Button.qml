import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property bool showText: false
    property bool showIcon: true

    property url source: ""
    property int iconSize: 16
    
    property string text: ""
    property string textColor: "white"
    property int textSize: 16 
    property bool textBold: false
    
    property int space: 14

    property alias mouse: m
    property var acceptedButtons: Qt.LeftButton
    property var onClicked: (event) => {}

    implicitWidth: row.implicitWidth + space
    implicitHeight: row.implicitHeight + space
    radius: 6
    color: m.containsMouse ? '#487f7f7f' : '#48080808'

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
            font.pixelSize: root.textSize
            font.bold: root.textBold
            visible: root.showText
        }
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