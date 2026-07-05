pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../services" as Services

ListView {
    id: resultsList
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: 2
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 150
    highlightMoveVelocity: -1

    highlight: Rectangle {
        radius: 8
        color: '#1e1e1e'
        visible: resultsList.currentIndex >= 0
    }

    delegate: Rectangle {
        id: delegateRoot
        required property var modelData
        required property int index

        property string urgencyColor: delegateRoot.modelData.urgency === NotificationUrgency.Critical ? "#f3a6a6" : delegateRoot.modelData.urgency === NotificationUrgency.Normal ? "#afafaf" : '#1c1c1c'

        width: resultsList.width
        implicitHeight: content.implicitHeight + 20
        radius: 8
        color: "transparent"
        border.width: 1
        border.color: urgencyColor
        
        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                NotificationImage {
                    isImage: (delegateRoot.modelData.image ?? "") !== ""
                    isAppIcon: (delegateRoot.modelData.appIcon ?? "") !== ""
                    image: delegateRoot.modelData.image
                    appIcon : {
                        var src = Quickshell.iconPath(delegateRoot.modelData.appIcon ?? "", true)
                        return src !== "" ? src : delegateRoot.modelData.appIcon
                    }
                }

                Text {
                    text: delegateRoot.modelData.summary ?? ""
                    color: resultsList.currentIndex === delegateRoot.index ? "#fff" : "#828282"
                    font.pixelSize: 16
                    font.bold: resultsList.currentIndex === delegateRoot.index
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: delegateRoot.modelData.time ?? ""
                    color: "#828282"
                    font.pixelSize: 16
                    elide: Text.ElideRight
                }
            }

            Text {
                text: delegateRoot.modelData.body ?? ""
                color: "#828282"
                font.pixelSize: 16
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.Notifications.history.remove(delegateRoot.index)
            onPositionChanged: resultsList.currentIndex = delegateRoot.index
        }

    }

    Text {
        anchors.centerIn: parent
        text: "No notifications found"
        color: '#828282'
        font.pixelSize: 16
        visible: resultsList.count === 0
    }
}