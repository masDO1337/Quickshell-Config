import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Text {
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: 600
    Layout.alignment: Qt.AlignCenter
    visible: Hyprland.activeToplevel?.title.length > 0
    text: Hyprland.activeToplevel?.title ?? ""
    elide: Text.ElideRight
    font.pixelSize: 13
    font.bold: true
    color: Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? "#e5f29c" : "#828282"
}