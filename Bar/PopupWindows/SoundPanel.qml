pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import "UI" as UI

Tooltip {
    id: root

    property int selected: 0

    Item {
        id: sound
        anchors.fill: parent
        implicitWidth: Math.max(380, column.implicitWidth)
        implicitHeight: column.implicitHeight

        property list<PwNode> playback: Pipewire.nodes.values.filter(n => n.audio !== null && n.isStream && n.isSink)
        property list<PwNode> recording: Pipewire.nodes.values.filter(n => n.audio !== null && n.isStream && !n.isSink)
        property list<PwNode> outputs: Pipewire.nodes.values.filter(n => n.audio !== null && !n.isStream && n.isSink)
        property list<PwNode> inputs: Pipewire.nodes.values.filter(n => n.audio !== null && !n.isStream && !n.isSink)
        property list<var> filter: [playback, recording, outputs, inputs]

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                UI.Button {
                    Layout.fillWidth: root.selected === 0
                    radius: 0
                    text: "Playback"
                    textBold: false
                    textColor: root.selected === 0 ? "#ffffff" : "#808080"
                    onClicked: () => { root.selected = 0 }
                }

                UI.Button {
                    Layout.fillWidth: root.selected === 1
                    radius: 0
                    text: "Recording"
                    textBold: false
                    textColor: root.selected === 1 ? "#ffffff" : "#808080"
                    onClicked: () => { root.selected = 1 }
                }

                UI.Button {
                    Layout.fillWidth: root.selected === 2
                    radius: 0
                    text: "Outputs"
                    textBold: false
                    textColor: root.selected === 2 ? "#ffffff" : "#808080"
                    onClicked: () => { root.selected = 2 }
                }

                UI.Button {
                    Layout.fillWidth: root.selected === 3
                    radius: 0
                    text: "Inputs"
                    textBold: false
                    textColor: root.selected === 3 ? "#ffffff" : "#808080"
                    onClicked: () => { root.selected = 3 }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            Repeater {
                model: sound.filter[root.selected]

                Item {
                    id: node

                    required property int index
                    required property PwNode modelData

                    Layout.fillWidth: true
                    Layout.preferredWidth: nodeColumn.implicitWidth
                    Layout.preferredHeight: nodeColumn.implicitHeight
                    Layout.margins: 20

                    PwObjectTracker { 
                        objects: [node.modelData]
                        onObjectsChanged: {
                            node.modelData = sound.filter[root.selected][node.index]
                        }
                    }

                    ColumnLayout {
                        id: nodeColumn
                        anchors.fill: parent
                        spacing: 16

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            UI.Button {
                                source: {
                                    const isSink = node.modelData.isSink
                                    const muted = node.modelData.audio?.muted
                                    const volume = node.modelData.audio?.volume
                                    
                                    if (!isSink && muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone-slash.svg"))
                                    if (!isSink) return Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone.svg"))
                                    if (muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-xmark.svg"))
                                    if (volume > 0.66) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-2.svg"))
                                    if (volume > 0.33) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-1.svg"))
                                    return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker.svg"))
                                }
                                onClicked: () => { node.modelData.audio.muted = !node.modelData.audio.muted }
                            }

                            Text { 
                                text: `${node.modelData.description !== "" ? node.modelData.description : node.modelData.name}`
                                color: "#a6e1f3"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text { 
                                text: `${Math.round(node.modelData.audio?.volume * 100)}%`
                                color: "#a6e1f3"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 4

                            UI.Slider {
                                from: 0
                                to: 1.5
                                stepSize: 0.05
                                snapMode: Slider.SnapOnRelease
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