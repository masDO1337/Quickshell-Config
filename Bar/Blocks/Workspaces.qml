import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets

ClippingRectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: row.implicitWidth
    Layout.topMargin: 2
    Layout.bottomMargin: 2
    color: "#1e1e1e"
    radius: 11

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 0
        
        Repeater {
            model: Hyprland.workspaces
            
            Rectangle {
                id: workspace

                required property int index
                required property HyprlandWorkspace modelData

                Layout.preferredHeight: 24
                Layout.preferredWidth: text.implicitWidth > text.implicitHeight ? text.implicitWidth + 16 : text.implicitHeight + 8

                color: modelData.urgent ? "#f3a6a6" : m.containsMouse ? "#7f7f7f" : '#00ffffff'

                Behavior on color {
                    ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                SequentialAnimation on opacity {
                    running: workspace.modelData.urgent
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.55
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        to: 1.0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                MouseArea {
                    id: m
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: () => {
                        if (workspace.modelData.id <= 0) Hyprland.dispatch("hl.dsp.workspace.toggle_special('" + workspace.modelData.name.split("special:")[1] + "')")
                        else Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspace.modelData.name + " })")
                    }
                }

                Text {
                    id: text
                    anchors.centerIn: parent
                    font.pixelSize: 13
                    font.bold: true
                    text: workspace.modelData.id <= 0 ? workspace.modelData.name.split("special:")[1] : workspace.modelData.name
                    color: workspace.modelData.focused ? "#f3a6a6" : m.containsMouse || workspace.modelData.urgent ? "#1e1e1e" : "#7f7f7f"
                }
            }
        }
    }
}