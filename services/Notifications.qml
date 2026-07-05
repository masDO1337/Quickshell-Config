pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root
    
    property ListModel history: ListModel {}
    
    readonly property NotificationServer server: NotificationServer {

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (notification) => {
            root.history.insert(0, {
                summary: notification.summary,
                body: notification.body,
                appName: notification.appName,
                image: notification.image,
                appIcon: notification.appIcon,
                urgency: notification.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            notification.tracked = true
        }
    }

    property int length: server.trackedNotifications.values.length
}