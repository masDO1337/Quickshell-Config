import Quickshell
import QtQuick
import QtQuick.Layouts
import "../PopupWindows"
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    implicitWidth: box.implicitWidth

    property bool showDate: false

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: root.showDate ? Qt.resolvedUrl(Quickshell.shellPath("Icons/calendar.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/clock-circle.svg"))

        showText: true
        text: root.showDate ? Qt.formatDateTime(systemClock.date, "dd / MM / yyyy") : Qt.formatDateTime(systemClock.date, "hh : mm")
        textColor: "#f3a6a6"

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (event) => {
            if (event.button == Qt.LeftButton) {
                calendarTooltip.toggle()
            } 
            if (event.button == Qt.RightButton) {
                root.showDate = !root.showDate
            }
        }
    }

    ClockPanel {
        id: calendarTooltip
        parentItem: root

        clock: systemClock
    }
}