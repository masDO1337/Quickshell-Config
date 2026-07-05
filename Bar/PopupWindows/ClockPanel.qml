pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import "UI" as UI

Tooltip {
    id: root

    property SystemClock clock

    Item {
        id: calendarPanel

        implicitWidth: 252
        implicitHeight: calendarColumn.implicitHeight

        property date shownDate: root.clock.date
        property int shownYear: shownDate.getFullYear()
        property int shownMonth: shownDate.getMonth()

        property bool isNotMonth: shownMonth !== root.clock.date.getMonth() || shownYear !== root.clock.date.getFullYear()

        function daysInMonth(year, month) {
            return new Date(year, month + 1, 0).getDate()
        }

        function firstDayOffset(year, month) {
            // Monday = 0, Sunday = 6
            return (new Date(year, month, 1).getDay() + 6) % 7
        }

        function isToday(day) {
            let now = root.clock.date
            return day === now.getDate() && shownMonth === now.getMonth() && shownYear === now.getFullYear()
        }

        function prevMonth() {
            shownDate = new Date(shownYear, shownMonth - 1, 1)
        }

        function nextMonth() {
            shownDate = new Date(shownYear, shownMonth + 1, 1)
        }

        function resetMonth() {
            shownDate = root.clock.date
        }

        ColumnLayout {
            id: calendarColumn
            width: parent.implicitWidth
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/angle-left.svg"))
                    onClicked: () => calendarPanel.prevMonth()
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(calendarPanel.shownDate, "MMMM yyyy")
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }

                UI.Button {
                    source: Qt.resolvedUrl(Quickshell.shellPath("Icons/angle-right.svg"))
                    onClicked: () => calendarPanel.nextMonth()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

                Repeater {
                    model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                    Text {
                        required property var modelData
                        
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 22
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: "#a0a0a0"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

                Repeater {
                    model: 42

                    Rectangle {
                        id: dayCell

                        required property var modelData
                        required property int index

                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32

                        property int offset: calendarPanel.firstDayOffset(calendarPanel.shownYear, calendarPanel.shownMonth)
                        property int currentMonthDays: calendarPanel.daysInMonth(calendarPanel.shownYear, calendarPanel.shownMonth)
                        property int previousMonthDays: calendarPanel.daysInMonth(calendarPanel.shownYear, calendarPanel.shownMonth - 1)

                        property bool inPreviousMonth: index < offset
                        property bool inNextMonth: index >= offset + currentMonthDays
                        property bool inCurrentMonth: !inPreviousMonth && !inNextMonth

                        property int dayNumber: inPreviousMonth
                            ? previousMonthDays - offset + index + 1
                            : inNextMonth
                                ? index - offset - currentMonthDays + 1
                                : index - offset + 1

                        property bool today: inCurrentMonth && calendarPanel.isToday(dayNumber)

                        radius: 8
                        color: today ? "#f3a6a6" : dayMouse.containsMouse ? "#3a3a3a" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.dayNumber
                            color: dayCell.today ? "#272727" : dayCell.inCurrentMonth ? "#ffffff" : "#666666"
                            font.pixelSize: 13
                            font.bold: dayCell.today
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }

            UI.Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true

                visible: calendarPanel.isNotMonth

                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/home.svg"))

                showText: true
                text: "Today"
                textColor: "#f3a6a6"
                textBold: true
                onClicked: () => calendarPanel.resetMonth()
            }
        }
    }
}