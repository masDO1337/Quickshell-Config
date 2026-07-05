pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../services" as Services

PanelWindow {
    id: notifications
    
    property bool showHistory: false

    function toggle() {
        showHistory = !showHistory
        grab.active = showHistory
    }
    
    visible: Services.Notifications.length > 0 || showHistory
    focusable: false
    
    anchors.top: true
    anchors.right: true
    margins.top: 40
    margins.right: showHistory ? screen.width / 2 - implicitWidth / 2 : 10

    implicitWidth: 360
    implicitHeight: notifications.showHistory ? 480 : Math.max(columnN.implicitHeight + 50, 10)

    color: 'transparent'
    //color: "red"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-notifications"

    exclusionMode: ExclusionMode.Ignore

    HyprlandFocusGrab {
        id: grab
        windows: [ notifications ]
    }
    
    Connections {
        target: grab
        function onCleared() {
            notifications.showHistory = false
        } 
    }

    Rectangle {
        anchors.fill: parent

        radius: 8
        border.width: 1
        border.color: "#afafaf"
        color: "#272727"

        visible: (Hyprland.focusedMonitor === Hyprland.monitorFor(notifications.screen)) && notifications.showHistory

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    color: "#fff"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                }

                Text {
                    text: `History ${Services.Notifications.history.count}`
                    color: "#828282"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                }

                Item { Layout.fillWidth: true }

                ExitButton {
                    text: "Clear All"
                    onClicked: () => Services.Notifications.history.clear()
                    visible: Services.Notifications.history.count > 0
                }
            }

            NotificationsListView {
                model: Services.Notifications.history
                currentIndex: 0
            }
        }
    }

    ColumnLayout {
        id: columnN
        width: parent.width
        spacing: 12
        visible: (Hyprland.focusedMonitor === Hyprland.monitorFor(notifications.screen)) && !notifications.showHistory

        Repeater {
            model: Services.Notifications.server.trackedNotifications

            Rectangle {
                id: notification
                required property Notification modelData
                required property int index

                property string urgencyColor: notification.modelData.urgency === NotificationUrgency.Critical ? "#f3a6a6" : notification.modelData.urgency === NotificationUrgency.Normal ? "#afafaf" : '#1c1c1c'
                property bool runTimer: Hyprland.focusedMonitor === Hyprland.monitorFor(notifications.screen) && !notification.hovered && notification.modelData.closed && notification.modelData.urgency !== NotificationUrgency.Critical
                property int intervalTimer: notification.modelData.expireTimeout > 0 ? notification.modelData.expireTimeout : notification.modelData.urgency === NotificationUrgency.Normal ? 8000 : 5000
                property alias t: timer

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 20
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
                    running: notification.runTimer
                    interval: notification.intervalTimer
                    onTriggered: {
                        notification.modelData.expire()
                    }
                }

                Rectangle {
                    width: 4
                    height: parent.height - 12
                    radius: 2
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: notification.urgencyColor
                }

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        NotificationImage {
                            isImage: (notification.modelData.image ?? "") !== ""
                            isAppIcon: (notification.modelData.appIcon ?? "") !== ""
                            image: notification.modelData.image
                            appIcon : {
                                var src = Quickshell.iconPath(notification.modelData.appIcon ?? "", true)
                                return src !== "" ? src : notification.modelData.appIcon
                            }
                        }
                            
                        Text {
                            text: notification.modelData.summary ?? ""
                            color: "#fff"
                            font.pixelSize: 16
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        ExitButton {
                            onClicked: () => {
                                notification.modelData.dismiss()
                            }
                        }
                    }

                    Text {
                        text: notification.modelData.body ?? ""
                        color: "#828282"
                        font.pixelSize: 16
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        Layout.fillWidth: true
                        visible: text !== ""
                    }
                    
                    ActionButtons {
                        n: notification
                    }

                    ProgressTimer {
                        n: notification
                    }
                }
            }
        }
    }
}