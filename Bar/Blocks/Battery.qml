import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../PopupWindows"
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    implicitWidth: box.implicitWidth
    visible: UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery

    property int percentage: UPower.displayDevice.percentage * 100
    property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging

    UI.Button {
        id: box
        anchors.centerIn: parent
 
        source: root.charging 
            ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-charge.svg")) 
            : root.percentage < 20 
            ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-empty.svg"))
            : root.percentage < 60 
            ? Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-half.svg")) 
            : Qt.resolvedUrl(Quickshell.shellPath("Icons/battery-full.svg"))

        text: root.percentage < 100 ? root.percentage + "%" : ""
        textColor: "#f3d9a6"
    }

    BatteryPanel {
        id: panel
        parentItem: root
        hover: box.mouse.containsMouse
    }
}