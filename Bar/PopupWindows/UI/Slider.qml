import QtQuick
import QtQuick.Controls

Slider {
    id: s
    anchors.fill: parent

    background: Rectangle {
        x: s.leftPadding
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.availableWidth
        height: 4
        radius: 2
        color: "#3c3c3c"

        Rectangle {
            width: s.visualPosition * parent.width
            height: parent.height
            color: "#4a9eff"
            radius: 2
        }
    }

    handle: Rectangle {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: 8
        color: s.pressed ? "#4a9eff" : "#ffffff"
        border.color: "#3c3c3c"
    }
}