import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import "UI" as UI

Tooltip {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: Mpris.players

            Rectangle {
                id: node

                required property int index
                required property MprisPlayer modelData

                function formatTime(seconds) {
                    if (!seconds || seconds < 0)
                        return "0:00"

                    const s = Math.floor(seconds)
                    const h = Math.floor(s / 3600)
                    const m = Math.floor((s % 3600) / 60)
                    const sec = s % 60

                    if (h > 0)
                        return `${h}:${String(m).padStart(2, "0")}:${String(sec).padStart(2, "0")}`

                    return `${m}:${String(sec).padStart(2, "0")}`
                }

                Layout.preferredWidth: Math.max(nodeColumn.implicitWidth + 20, 320)
                Layout.preferredHeight: 180
                color: "transparent"

                Item {
                    anchors.fill: parent
                    anchors.margins: 4

                    visible: node.modelData.trackArtUrl !== ""

                    Image {
                        id: sourceImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: Qt.resolvedUrl(node.modelData.trackArtUrl)
                        visible: false
                    }

                    MultiEffect {
                        anchors.fill: sourceImage
                        source: sourceImage

                        maskEnabled: true
                        maskSource: mask
                    }

                    Item {
                        id: mask
                        width: sourceImage.width
                        height: sourceImage.height
                        layer.enabled: true
                        visible: false

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: sourceImage
                        color: '#8f000000'
                        radius: 4
                    }
                }

                ColumnLayout {
                    id: nodeColumn
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Text {
                        elide: Text.ElideRight
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        text: `${node.modelData.trackTitle || "Unknown Title"}`
                        Layout.maximumWidth: 320
                    }

                    Text {
                        elide: Text.ElideRight
                        color: "white"
                        font.pixelSize: 13
                        text: `${node.modelData.trackArtist || "Unknown Artist"}`
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        UI.Button {
                            source: node.modelData.canGoPrevious ? Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-backward.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-backward-2.svg"))
                            onClicked: () => {
                                if (node.modelData.canGoPrevious) node.modelData.previous()
                            }
                        }

                        UI.Button {
                            visible: node.modelData.canTogglePlaying
                            source: node.modelData.isPlaying ? Qt.resolvedUrl(Quickshell.shellPath("Icons/pause.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/play.svg"))
                            onClicked: () => {
                                if (node.modelData.canTogglePlaying) node.modelData.togglePlaying()
                            }
                        }

                        UI.Button {
                            source: node.modelData.canGoNext ? Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-forward.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-forward-2.svg"))
                            onClicked: () => {
                                if (node.modelData.canGoNext) node.modelData.next()
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            elide: Text.ElideRight
                            color: "white"
                            font.pixelSize: 13
                            text: node.formatTime(node.modelData.position ?? 0)
                        }
                        
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 16

                            Timer {
                                interval: 1000
                                repeat: true
                                running: node.modelData.isPlaying ?? false

                                // Quickshell position usually does not update reactively.
                                onTriggered: node.modelData.positionChanged()
                            }

                            UI.Slider {
                                enabled: node.modelData.positionSupported ?? false
                                from: 0
                                to: node.modelData.length ?? 1

                                value: pressed ? value : node.modelData.position ?? 0

                                onMoved: {
                                    if (node.modelData.canSeek && node.modelData.positionSupported)
                                        node.modelData.position = value
                                }
                            }
                        }

                        Text {
                            elide: Text.ElideRight
                            color: "white"
                            font.pixelSize: 13
                            text: node.formatTime(node.modelData.length ?? 0)
                        }
                    }
                }
            }
        }
    }
}