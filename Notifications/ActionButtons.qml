pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

RowLayout {
    id: root
    property var n: undefined

    Layout.fillWidth: true
    spacing: 6
    visible: n.modelData?.actions.length > 0

    Repeater {
        model: root.n.modelData?.actions

        Rectangle {
            id: actionBtn
            required property NotificationAction modelData

            Layout.preferredHeight: 26
            Layout.fillWidth: true
            border.width: 1
            border.color: root.n.urgencyColor
            color: actionHover.containsMouse ? '#1e1e1e' : "transparent"

            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            Text {
                id: actionText
                anchors.centerIn: parent
                text: actionBtn.modelData.text || ""
                color: "#fff"
                font.pixelSize: 16
            }

            MouseArea {
                id: actionHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: actionBtn.modelData.invoke()
            }
        }
    }
}