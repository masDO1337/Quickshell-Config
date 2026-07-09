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
            radius: 6
            color: actionHover.containsMouse ? '#487f7f7f' : '#1e1e1e'

            Behavior on color {
                ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
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