import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../PopupWindows"

Tooltip {
    id: root

    Item {
        id: battery
        anchors.fill: parent
        implicitWidth: Math.max(380, row.implicitWidth)
        implicitHeight: row.implicitHeight

        property int percentage: UPower.displayDevice.percentage * 100
        
        function getToFull() {
            var s = UPower.displayDevice.timeToFull
            return Math.round(s / 3600) + "h " + Math.round(s / 60) % 60 + "m " + s % 60 + "s"
        }

        function getToEmpty() {
            var s = UPower.displayDevice.timeToEmpty
            return Math.round(s / 3600) + "h " + Math.round(s / 60) % 60 + "m " + s % 60 + "s"
        }

        RowLayout {
            id: row
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.leftMargin: 20
                Layout.topMargin: 20
                Layout.bottomMargin: 20

                color: '#7f7f7f'
                radius: 32

                visible: Quickshell.iconPath(UPower.displayDevice.iconName, true) !== ""

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 48
                    source: Quickshell.iconPath(UPower.displayDevice.iconName, true)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20

                Text {
                    Layout.fillWidth: true
                    text: `Level: ${battery.percentage}%`
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: `Capacity: ${UPower.displayDevice.energyCapacity.toFixed(2)} W/h`
                    color: "#808080"
                    font.pixelSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: `Energy: ${UPower.displayDevice.energy.toFixed(2)} W/h`
                    color: "#808080"
                    font.pixelSize: 12
                }

            }

            ColumnLayout {
                Layout.margins: 20

                Text {
                    text: `Status: ${UPowerDeviceState.toString(UPower.displayDevice.state)}`
                    color: "#808080"
                    font.pixelSize: 12
                }

                Text {
                    text: `Health: ${UPower.displayDevice.healthPercentage * 100}%`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: UPower.displayDevice.healthSupported
                }

                Text {
                    text: `Time full: ${battery.getToFull()}`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: UPower.displayDevice.state === UPowerDeviceState.Charging
                }

                Text {
                    text: `Time Empty: ${battery.getToEmpty()}`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: UPower.displayDevice.state === UPowerDeviceState.Discharging
                }

                Text {
                    text: `Change Rate: ${UPower.displayDevice.changeRate.toFixed(2)}W`
                    color: "#808080"
                    font.pixelSize: 12
                    visible: UPower.displayDevice.state === UPowerDeviceState.Discharging || UPower.displayDevice.state === UPowerDeviceState.Charging
                }
            }
        }
    }
}