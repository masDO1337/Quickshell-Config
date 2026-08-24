import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property string source: ""
    property int iconSize: 16
    
    property string text: ""
    property string textColor: "white"
    property int textSize: 16 
    property bool textBold: true

    property alias mouse: m
    property var acceptedButtons: Qt.LeftButton
    property var onClicked: (event) => {}

    implicitWidth: row.implicitWidth + 16
    implicitHeight: row.implicitHeight + 12
    radius: 6
    color: m.containsMouse ? '#707f7f7f' : "#1e1e1e"

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
            visible: root.source.length > 0
        }

        Text {
            text: root.text
            color: root.textColor
            font.pixelSize: root.textSize
            font.bold: root.textBold
            visible: root.text.length > 0
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