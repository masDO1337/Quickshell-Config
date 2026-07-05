import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "UI" as UI

Rectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: row.implicitWidth
    Layout.topMargin: 2
    Layout.bottomMargin: 2
    color: "#1e1e1e"
    radius: 8

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 0
        
        Repeater {
            model: Hyprland.workspaces
            
            UI.Button {
                id: workspace

                required property HyprlandWorkspace modelData
                required property int index

                spaseWidth: 16

                color: mouse.containsMouse ? "#828282" : '#00ffffff'

                showIcon: false
                showText: true
                text: modelData.id <= 0 ? modelData.name.split("special:")[1] : modelData.name
                textColor: modelData.focused ? "#f3a6a6" : mouse.containsMouse ? "#1e1e1e" : "#828282"

                onClicked: () => {
                    if (modelData.id <= 0) {
                        Hyprland.dispatch("hl.dsp.workspace.toggle_special('" + modelData.name.split("special:")[1] + "')")
                    }
                    else Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.name + " })")
                }
            }
        }
    }
}