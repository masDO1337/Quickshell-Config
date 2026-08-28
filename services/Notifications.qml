pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property FileView file: FileView {
        path: Quickshell.cachePath("notifications.json")

        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property list<var> history: []
            property int maxHistory: 100

            function add(notification: Notification) {
                let obj = {
                    summary: notification.summary,
                    body: notification.body,
                    appName: notification.appName,
                    image: notification.image,
                    appIcon: notification.appIcon,
                    urgency: notification.urgency,
                    time: new Date().toISOString()
                }
                history = [obj, ...history].slice(0, maxHistory)
            }
            
            function remove(index) {
                if (index < 0 || index >= history.length) return

                history = history.slice(0, index).concat(
                    history.slice(index + 1)
                )
            }
        }
    }
    
    readonly property NotificationServer server: NotificationServer {

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (notification) => {
            root.file.adapter.add(notification)
            notification.tracked = true
        }
    }

    property int length: server.trackedNotifications.values.length

    property list<var> history: file.adapter.history
    property int historyLength: history.length


    function clear() {
        file.adapter.history = []
    }

    function remove(index: int) {
        if (index === undefined) return
        file.adapter.remove(index)
    }
}