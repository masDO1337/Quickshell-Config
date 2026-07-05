import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services" as Services
import "UI" as UI

PanelWindow {
    id: root
    
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
        body.currentIndex = 0
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
    }
    
    Connections {
        target: grab
        function onCleared() {
            root.off()
        } 
    }

    Shortcut {
        sequence: "ESCAPE"
        onActivated: root.off()
    }

    Shortcut {
        sequence: "Up"
        onActivated: body.currentIndex = Math.max(body.currentIndex - 1, 1)
    }

    Shortcut {
        sequence: "Down"
        onActivated: body.currentIndex = Math.min(body.currentIndex + 1, 4)
    }

    Shortcut {
        sequence: "Return"
        onActivated: {
            if (body.currentIndex === 0) return
            switch(body.currentIndex) {
            case 1:
                Services.PowerMenu.lock.running = true
                root.off()
                break;
            case 2:
                Services.PowerMenu.logout.running = true
                root.off()
                break;
            case 3:
                Services.PowerMenu.reboot.running = true
                root.off()
                break;
            case 4:
                Services.PowerMenu.poweroff.running = true
                root.off()
                break;
            }
        }
    }

    Rectangle {
        id: body

        property int currentIndex: 0

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

            UI.Button {
                index: 1
                currentIndex: body.currentIndex
                text: "Lock"
                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-lock.svg"))
                onClicked: () => {Services.PowerMenu.lock.running = true; root.off()}
                onEntered: index => {body.currentIndex = index}
            }

            UI.Button {
                index: 2
                currentIndex: body.currentIndex
                text: "Logout"
                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-logout.svg"))
                onClicked: () => {Services.PowerMenu.logout.running = true; root.off()}
                onEntered: index => {body.currentIndex = index}
            }

            UI.Button {
                index: 3
                currentIndex: body.currentIndex
                text: "Reboot"
                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-reboot.svg"))
                onClicked: () => {Services.PowerMenu.reboot.running = true; root.off()}
                onEntered: index => {body.currentIndex = index}
            }

            UI.Button {
                index: 4
                currentIndex: body.currentIndex
                text: "Power Off"
                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/system-shutdown.svg"))
                onClicked: () => {Services.PowerMenu.poweroff.running = true; root.off()}
                onEntered: index => {body.currentIndex = index}
            }
        }
    }
}
