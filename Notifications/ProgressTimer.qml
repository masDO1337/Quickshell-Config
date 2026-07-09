import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Rectangle {
    id: root
    
    property var n: undefined
    
    Layout.fillWidth: true
    height: 2
    color: "#1e1e1e"
    radius: 1
    Layout.topMargin: 2
    visible: n.modelData.urgency === NotificationUrgency.Normal

    Rectangle {
        id: progressBar

        property var initWidth: parent.width
        
        height: parent.height
        width: parent.width
        radius: 1
        color: root.n.urgencyColor
        opacity: 0.6

        SequentialAnimation {
            running: root.n.runTimer
            PauseAnimation { duration: 50 }
            NumberAnimation {
                target: progressBar
                property: "width"
                from: progressBar.initWidth
                to: 0
                duration: root.n.intervalTimer
            }
        }
    }
}