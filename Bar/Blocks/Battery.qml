import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../services" as Services

Item {
    id: root
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 4

        IconImage {
            implicitSize: 14
            source: Services.Battery.charging 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-charging.svg")) 
                : Services.Battery.percentage < 20 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-empty.svg")) 
                : Services.Battery.percentage < 60 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-half.svg")) 
                : Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-full.svg"))
        }

        Text {
            text: Services.Battery.percentage + "%"
            font.pixelSize: 13
            font.bold: true
            color: "#f3d9a6"
            visible: Services.Battery.percentage < 100
        }
    }
}