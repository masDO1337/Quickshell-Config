import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import "UI" as UI

Tooltip {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

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

                Layout.preferredWidth: 320
                Layout.preferredHeight: 180
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl(node.modelData.trackArtUrl)
                    visible: node.modelData.trackArtUrl !== ""
                }
                    
                Rectangle {
                    anchors.fill: parent
                    color: '#8f000000'
                    radius: 4
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        text: `${node.modelData.trackTitle || "Unknown Title"}`
                    }

                    Text {
                        Layout.fillWidth: true
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
                            source: Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-backward.svg"))
                            onClicked: () => node.modelData.previous()
                            visible: node.modelData.canGoPrevious
                        }

                        UI.Button {
                            source: node.modelData.isPlaying ? Qt.resolvedUrl(Quickshell.shellPath("Icons/pause.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/play.svg"))
                            onClicked: () => node.modelData.togglePlaying()
                            visible: node.modelData.canTogglePlaying
                        }

                        UI.Button {
                            source: Qt.resolvedUrl(Quickshell.shellPath("Icons/skip-forward.svg"))
                            onClicked: () => node.modelData.next()
                            visible: node.modelData.canGoNext
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
                                running: node.modelData.playbackState == MprisPlaybackState.Playing

                                // Quickshell position usually does not update reactively.
                                onTriggered: node.modelData.positionChanged()
                            }

                            UI.Slider {
                                enabled: node.modelData.positionSupported ?? false
                                from: 0
                                to: node.modelData.length ?? 1

                                value: node.modelData.position ?? 0

                                onMoved: {
                                    if (node.modelData.canSeek && node.modelData.positionSupported)
                                        node.modelData.position = value
                                        node.modelData.positionChanged()
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