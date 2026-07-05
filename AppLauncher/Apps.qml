pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../services" as Services
import "UI" as UI

ListView {
    
    property var onClicked: null    

    id: resultsList
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: 0
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 150
    highlightMoveVelocity: -1

    highlight: Rectangle {
        radius: 8
        color: '#1e1e1e'
        visible: resultsList.currentIndex >= 0

        Rectangle {
            width: 3
            height: 24
            radius: 2
            color: "#808080"
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    delegate: Rectangle {
        id: delegateRoot
        required property var modelData
        required property int index

        width: resultsList.width
        height: 50
        radius: 8
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: resultsList.onClicked(delegateRoot.modelData)
            onPositionChanged: resultsList.currentIndex = delegateRoot.index
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // App icon
            Item {
                width: 28
                height: 28
                Layout.alignment: Qt.AlignVCenter

                IconImage {
                    anchors.fill: parent
                    implicitSize: 28
                    source: Quickshell.iconPath(delegateRoot.modelData.icon ?? "", true)
                    visible: Quickshell.iconPath(delegateRoot.modelData.icon ?? "", true) !== ""
                }

                // Fallback icon
                Text {
                    anchors.centerIn: parent
                    text: "App"
                    color: "#fff"
                    font.pixelSize: 20
                    visible: Quickshell.iconPath(delegateRoot.modelData.icon ?? "", true) === ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                Text {
                    text: delegateRoot.modelData.name ?? ""
                    color: resultsList.currentIndex === delegateRoot.index ? "#fff" : "#828282"
                    font.pixelSize: 13
                    font.bold: resultsList.currentIndex === delegateRoot.index
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: delegateRoot.modelData.comment ?? delegateRoot.modelData.genericName ?? ""
                    color: "#828282"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: text !== ""
                }
            }

            UI.Button {
                id: resetButton
                showText: !resetButton.mouse.containsMouse
                showIcon: resetButton.mouse.containsMouse
                Layout.alignment: Qt.AlignVCenter
                source: Qt.resolvedUrl(Quickshell.shellPath("Icons/x.svg"))
                text: `${Services.AppLauncher.count(delegateRoot.modelData)}`
                visible: Services.AppLauncher.count(delegateRoot.modelData) > 0
                onClicked: () => {Services.AppLauncher.reset(delegateRoot.modelData)}
            }
        }

    }

    Text {
        anchors.centerIn: parent
        text: "  No applications found"
        color: '#828282'
        font.pixelSize: 16
        visible: resultsList.count === 0
    }
}