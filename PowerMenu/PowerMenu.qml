pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "UI" as UI

PanelWindow {
    id: root
    
    property int currentIndex: 0
    property list<var> menu: [
        {
            text: "Lock",
            icon: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-lock.svg")),
            run: ["hyprlock"]
        },
        {
            text: "Logout",
            icon: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-logout.svg")),
            run: ["uwsm", "stop"]
        },
        {
            text: "Reboot",
            icon: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-reboot.svg")),
            run: ["systemctl", "reboot"]
        },
        {
            text: "Power Off",
            icon: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-shutdown.svg")),
            run: ["systemctl", "poweroff"]
        }
    ]


    visible: false
    focusable: false

    implicitWidth: 250
    implicitHeight: body.implicitHeight

    anchors.right: true
    margins.right: -implicitWidth - 20

    SequentialAnimation {
        running: root.visible
        NumberAnimation {
            target: root
            property: "margins.right"
            to: 10
            duration: 360
        }
    }
    
    color: 'transparent'

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-powerMenu"

    exclusionMode: ExclusionMode.Ignore

    function toggle() {
        visible = !visible
        grab.active = visible
        if (!visible) off()
    }

    function off() {
        visible = false
        margins.right = -implicitWidth - 20
        root.currentIndex = 0
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onCleared: {
            root.off()
        }
    }

    Shortcut {
        sequence: "ESCAPE"
        onActivated: root.off()
    }

    Shortcut {
        sequence: "Up"
        onActivated: root.currentIndex = Math.max(root.currentIndex - 1, 0)
    }

    Shortcut {
        sequence: "Down"
        onActivated: root.currentIndex = Math.min(root.currentIndex + 1, root.menu.length - 1)
    }

    Shortcut {
        sequence: "Return"
        onActivated: {
            if (root.currentIndex < 0 || root.currentIndex > root.menu.length - 1) return
            root.off()
            Quickshell.execDetached(root.menu[root.currentIndex].run)
        }
    }

    Rectangle {
        id: body
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: Math.max(content.implicitWidth + 20, 50)
        implicitHeight: Math.max(content.implicitHeight + 20, 50)

        Behavior on implicitWidth {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        radius: 8
        border.width: 1
        border.color: '#afafaf'
        color: "#272727"

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Repeater {
                model: root.menu

                UI.Button {
                    required property int index
                    required property var modelData

                    on: mouse.containsMouse || index === root.currentIndex

                    text: modelData.text
                    source: modelData.icon
                    onClicked: () => {
                        root.off()
                        Quickshell.execDetached(root.menu[root.currentIndex].run)
                    }
                    onEntered: index => {root.currentIndex = index}
                }
            }
        }
    }
}
