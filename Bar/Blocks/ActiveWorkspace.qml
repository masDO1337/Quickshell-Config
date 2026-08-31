import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

Item {
    Layout.fillHeight: true
    Layout.preferredWidth: row.implicitWidth
    id: root

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 4

        IconImage {
            implicitSize: 16
            source: Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? Qt.resolvedUrl(Quickshell.shellPath("Icons/app-window.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/app-window-unfocus.svg"))
        }

        Text {
            text: Hyprland.activeToplevel?.title || ""
            Layout.maximumWidth: 600
            elide: Text.ElideRight
            font.pixelSize: 13
            font.bold: true
            color: Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? "#e5f29c" : "#828282"
        }
    }
}