pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

LazyLoader {
    id: root

    property Item parentItem: null
    property bool hover: false

    onHoverChanged: {
        if (hover) {
            loading = true
            hideTimer.stop()
        }
        else hideTimer.start()
    }

    active: false
    
    onActiveChanged: {
        if (!hover && active) item.grabFocus = true
        if (hover && active) item.grabFocus = false
    }

    function toggle() {
        if (active) {
            if (!hover) item.grabFocus = false
            active = false
        } else {
            loading = true
        }
    }

    property Timer hideTimer: Timer {
        interval: 450
        onTriggered: root.active = false
    }

    required default property Component contentDelegate

    PopupWindow {
        id: popup

        anchor {
            item: root.parentItem
            edges: Edges.Bottom
            gravity: Edges.Bottom
            rect.x: root.parentItem ? root.parentItem.width / 2 : 0
            rect.y: root.parentItem ? root.parentItem.height + 10 : 0
        }

        visible: true
        grabFocus: false

        onVisibleChanged: {
            if (!visible && !root.hover && root.active) root.active = false
        }

        color: "transparent"

        implicitWidth: body.implicitWidth
        implicitHeight: body.implicitHeight

        Rectangle {
            id: body

            anchors.fill: parent
            implicitWidth: content.implicitWidth
            implicitHeight: content.implicitHeight

            Behavior on implicitWidth {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }

            Behavior on implicitHeight {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }
            
            radius: 8
            border.width: 1
            border.color: '#afafaf'
            color: "#272727"

            Loader {
                id: content
                anchors.fill: parent
                sourceComponent: root.contentDelegate
                active: true
            }
        }
    }
}