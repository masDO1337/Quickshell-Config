import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland

Item {
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth
    id: activeWorkspace

    property string title: ""

    Process {
        id: titleProc
        command: ["sh", "-c", "hyprctl activewindow | grep title: | sed 's/^[^:]*: //'"]
        running: true

        stdout: SplitParser {
            onRead: data => activeWorkspace.title = data
        }
    }

    Component.onCompleted: {
        Hyprland.rawEvent.connect(hyprEvent)
    }

    function hyprEvent(e) {
        titleProc.running = true
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 2

        IconImage {
            implicitSize: 16
            source: Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? Qt.resolvedUrl(Quickshell.shellPath("Icons/app-window.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/app-window-unfocus.svg"))
        }

        Text {
            text: activeWorkspace.title
            Layout.maximumWidth: 600
            elide: Text.ElideRight
            font.pixelSize: 13
            font.bold: true
            color: Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? "#e5f29c" : "#CCCCCC"
        }
    }
}