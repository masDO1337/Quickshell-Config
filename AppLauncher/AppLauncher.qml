import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services" as Services

PanelWindow {
    id: launcherPanel
    
    visible: false
    focusable: false

    implicitWidth: body.implicitWidth
    implicitHeight: body.implicitHeight
    
    color: 'transparent'

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"

    exclusionMode: ExclusionMode.Ignore

    function toggle() {
        visible = !visible
        grab.active = visible
        if (visible) {
            input.text = ""
            output.currentIndex = 0
            output.positionViewAtIndex(output.currentIndex, ListView.Contain);
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ launcherPanel ]
    }
    
    Connections {
        target: grab
        function onCleared() {
            launcherPanel.visible = false
        } 
    }

    Shortcut {
        sequence: "ESCAPE"
        onActivated: launcherPanel.visible = false
    }

    function appRun(entry) {
        Services.AppLauncher.increment(entry)
        entry.execute();
        launcherPanel.toggle()
    }

    Rectangle {
        id: body

        anchors.centerIn: parent
        implicitWidth: Math.max(content.implicitWidth + 20, 580)
        implicitHeight: Math.max(content.implicitHeight + 20, 480)

        radius: 8
        border.width: 1
        border.color: '#afafaf'
        color: "#272727"

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            SearchBar {
                id: input
                onTextChanged: {
                    Services.AppLauncher.input = text
                    output.currentIndex = 0
                }
                onPressed: event => {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                        event.accepted = true;
                        output.currentIndex = Math.min(output.currentIndex + 1, output.count - 1);
                        output.positionViewAtIndex(output.currentIndex, ListView.Contain);
                    } else if (event.key === Qt.Key_Up) {
                        event.accepted = true;
                        output.currentIndex = Math.max(output.currentIndex - 1, 0);
                        output.positionViewAtIndex(output.currentIndex, ListView.Contain);
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        if (output.currentIndex >= 0) {
                            const entry = Services.AppLauncher.filteredApps.values[output.currentIndex];
                            if (entry) launcherPanel.appRun(entry)
                        }
                    }
                }
            }

            Text {
                text: output.count + " application" + (output.count !== 1 ? "s" : "")
                color: '#828282'
                font.pixelSize: 11
            }

            Apps {
                id: output
                model: Services.AppLauncher.filteredApps
                currentIndex: 0
                onClicked: entry => launcherPanel.appRun(entry)
            }
        }
    }
}