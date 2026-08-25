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
        color: '#1e1e1e'

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
        width: 6
        height: 6
        radius: 4
        color: "#ffffff"
        visible: s.pressed || s.hovered
    }
}