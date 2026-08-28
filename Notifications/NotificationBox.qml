import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Notifications

ClippingRectangle {
    id: root
    required property Notification modelData
    required property int index
    required property var screen

    property string urgencyColor: modelData.urgency === NotificationUrgency.Critical ? "#f3a6a6" : modelData.urgency === NotificationUrgency.Normal ? "#afafaf" : '#1c1c1c'
    property bool runTimer: Hyprland.focusedMonitor === Hyprland.monitorFor(screen) && !hovered && modelData.closed && modelData.urgency !== NotificationUrgency.Critical
    property int intervalTimer: modelData.expireTimeout > 0 ? modelData.expireTimeout : modelData.urgency === NotificationUrgency.Normal ? 6000 : 4000

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight
    radius: 8
    border.width: 1
    border.color: urgencyColor
    color: "#272727"

    property alias hovered: hover.hovered

    HoverHandler {
        id: hover
    }

    Timer {
        id: timer
        running: root.runTimer
        interval: root.intervalTimer
        onTriggered: {
            root.modelData.expire()
        }
    }

    ColumnLayout {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 16
            visible: !root.hovered

            Item {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                ClippingRectangle {
                    anchors.fill: parent
                    radius: 32
                    color: "transparent"

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 64
                        source: {
                            const isImage = (root.modelData.image ?? "") !== ""
                            const src = Quickshell.iconPath(root.modelData.appIcon ?? "", true)
                            return isImage ? root.modelData.image : src !== "" ? src : root.modelData.appIcon
                        }
                    }
                }

                IconImage {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    implicitSize: 24
                    source: {
                        var src = Quickshell.iconPath(root.modelData.appIcon ?? "", true)
                        return src !== "" ? src : root.modelData.appIcon
                    }
                    visible: (root.modelData.image ?? "") !== ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    Layout.fillWidth: true
                    text: root.modelData.summary ?? ""
                    color: "#fff"
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.modelData.body ?? ""
                    color: "#828282"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                    visible: text !== ""
                }
            }

            ExitButton {
                onClicked: () => root.modelData.dismiss()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 16
            visible: root.hovered

            Text {
                text: root.modelData.body ?? ""
                color: "#fff"
                font.pixelSize: 16
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                textFormat: Text.PlainText
                Layout.fillWidth: true
                visible: text !== ""
            }

            ExitButton {
                onClicked: () => root.modelData.dismiss()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: root.urgencyColor
            visible: root.modelData.body ?? "" !== ""
        }

        Item {
            Layout.fillWidth: true
            Layout.margins: 0
            Layout.preferredWidth: actionsRow.implicitWidth
            Layout.preferredHeight: actionsRow.implicitHeight + 20

            Rectangle {
                id: progressBar

                property int initWidth: parent.width
                
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: parent.width
                color: root.urgencyColor

                SequentialAnimation {
                    running: root.runTimer
                    PauseAnimation { duration: 50 }
                    NumberAnimation {
                        target: progressBar
                        property: "width"
                        from: progressBar.initWidth
                        to: 0
                        duration: root.intervalTimer
                    }
                }
            }
        
            RowLayout {
                id: actionsRow
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6
                visible: root.modelData?.actions.length > 0

                Repeater {
                    model: root.modelData?.actions

                    Rectangle {
                        id: actionBtn
                        required property NotificationAction modelData

                        Layout.preferredHeight: 26
                        Layout.fillWidth: true
                        radius: 6
                        color: actionHover.containsMouse ? '#7f7f7f' : '#1e1e1e'

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
        }
    }
}