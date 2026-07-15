pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "UI" as UI

Tooltip {
    Item {
        id: sound
        anchors.centerIn: parent
        implicitWidth: column.implicitWidth
        implicitHeight: column.implicitHeight

        property PwNode sink: Pipewire.defaultAudioSink
        property PwNode source: Pipewire.defaultAudioSource

        property list<PwNode> filter: Pipewire.nodes.values.filter(n => n.audio !== null && n.isStream && n.isSink)

        PwObjectTracker { 
            objects: [Pipewire.defaultAudioSource]
            onObjectsChanged: {
                sound.source = Pipewire.defaultAudioSource
            }
        }

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 4

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    IconImage {
                        implicitSize: 16
                        source: {
                            const muted = sound.sink?.audio?.muted
                            const volume = sound.sink?.audio?.volume;
                            
                            if (muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-xmark.svg"))
                            if (volume > 0.66) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-2.svg"))
                            if (volume > 0.33) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-1.svg"))
                            return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker.svg"))
                        }
                    }

                    Text { 
                        text: `${sound.sink?.description !== "" ? sound.sink?.description : sound.sink?.name}`
                        color: "#a6e1f3"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text { 
                        text: `${Math.round(sound.sink?.audio?.volume * 100)}%`
                        color: "#a6e1f3"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    UI.Button {
                        showIcon: false
                        showText: true
                        text: sound.sink?.audio?.muted ? "unmute" : "mute"
                        textSize: 13
                        onClicked: () => { sound.sink.audio.muted = !sound.sink.audio.muted }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 16

                    UI.Slider {
                        from: 0
                        to: 1
                        value: sound.sink?.audio?.volume || 0
                        onValueChanged: {
                            if (sound.sink?.audio) {
                                sound.sink.audio.volume = value
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    IconImage {
                        implicitSize: 16
                        source: sound.source?.audio?.muted ? Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone-slash.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone.svg"))
                    }

                    Text { 
                        text: `${sound.source?.description !== "" ? sound.source?.description : sound.source?.name}`
                        color: "#a6e1f3"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text { 
                        text: `${Math.round(sound.source?.audio?.volume * 100)}%`
                        color: "#a6e1f3"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    UI.Button {
                        showIcon: false
                        showText: true
                        text: sound.source?.audio?.muted ? "unmute" : "mute"
                        textSize: 13
                        onClicked: () => { sound.source.audio.muted = !sound.source.audio.muted }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 16

                    UI.Slider {
                        from: 0
                        to: 1
                        value: sound.source?.audio?.volume || 0
                        onValueChanged: {
                            if (sound.source?.audio) {
                                sound.source.audio.volume = value
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
                visible: sound.filter.length > 0
            }

            Text {
                Layout.fillWidth: true
                Layout.margins: 10
                text: "Playback"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                visible: sound.filter.length > 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 10

                spacing: 6

                visible: sound.filter.length > 0

                Repeater {
                    model: sound.filter

                    Rectangle {
                        id: node

                        required property int index
                        required property PwNode modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: nodeColumn.implicitHeight
                        color: "transparent"
                        
                        radius: 4

                        PwObjectTracker { 
                            objects: [node.modelData]
                            onObjectsChanged: {
                                node.modelData = sound.filter[node.index]
                            }
                        }

                        ColumnLayout {
                            id: nodeColumn
                            anchors.fill: parent

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                IconImage {
                                    implicitSize: 16
                                    source: {
                                        const muted = node.modelData.audio?.muted
                                        const volume = node.modelData.audio?.volume;
                                        
                                        if (muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-xmark.svg"))
                                        if (volume > 0.66) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-2.svg"))
                                        if (volume > 0.33) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-1.svg"))
                                        return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker.svg"))
                                    }
                                }

                                Text { 
                                    text: `${node.modelData.description !== "" ? node.modelData.description : node.modelData.name}`
                                    color: "#a6e1f3"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text { 
                                    text: `${Math.round(node.modelData.audio?.volume * 100)}%`
                                    color: "#a6e1f3"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }

                                UI.Button {
                                    showIcon: false
                                    showText: true
                                    text: node.modelData.audio.muted ? "unmute" : "mute"
                                    textSize: 12
                                    onClicked: () => {
                                        node.modelData.audio.muted = !node.modelData.audio.muted
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                implicitHeight: 16

                                UI.Slider {
                                    from: 0
                                    to: 1
                                    value: node.modelData.audio?.volume || 0
                                    onValueChanged: {
                                        if (node.modelData.audio) {
                                            node.modelData.audio.volume = value
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}