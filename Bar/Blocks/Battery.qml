import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Item {
    id: root
    Layout.fillHeight: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4
    implicitWidth: row.implicitWidth
    visible: UPower.displayDevice.ready

    property int percentage: UPower.displayDevice.percentage * 100
    property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 4

        IconImage {
            implicitSize: 14
            source: root.charging 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-charge.svg")) 
                : root.percentage < 20 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-empty.svg"))
                : root.percentage < 60 
                ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-half.svg")) 
                : Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-full.svg"))
        }

        Text {
            text: root.percentage + "%"
            font.pixelSize: 13
            font.bold: true
            color: "#f3d9a6"
            visible: root.percentage < 100
        }
    }
}