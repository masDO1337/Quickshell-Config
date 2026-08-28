pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services" as Services

PanelWindow {
    id: notifications
    
    visible: Services.Notifications.length > 0
    focusable: false
    
    anchors.top: true
    anchors.right: true
    margins.top: 30

    implicitWidth: 380
    implicitHeight: column.implicitHeight + 10

    color: 'transparent'
    //color: "red"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-notifications"

    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        spacing: 5
        visible: Hyprland.focusedMonitor === Hyprland.monitorFor(notifications.screen)

        Repeater {
            model: Services.Notifications.server.trackedNotifications

            NotificationBox {
                screen: notifications.screen
            }
        }
    }
}