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

        property list<PwNode> playback:  Pipewire.nodes.values.filter(n => n.audio !== null &&  n.isStream &&  n.isSink)
        property list<PwNode> recording: Pipewire.nodes.values.filter(n => n.audio !== null &&  n.isStream && !n.isSink)
        property list<PwNode> outputs:   Pipewire.nodes.values.filter(n => n.audio !== null && !n.isStream &&  n.isSink)
        property list<PwNode> inputs:    Pipewire.nodes.values.filter(n => n.audio !== null && !n.isStream && !n.isSink)
        property list<var> mode: [playback, recording, outputs, inputs]

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: ["Playback", "Recording", "Outputs", "Inputs"]

                    UI.Button {
                        required property int index
                        required property string modelData

                        Layout.fillWidth: root.selected === index

                        radius: 0
                        text: modelData
                        textBold: false
                        textColor: root.selected === index ? "#ffffff" : "#808080"
                        onClicked: () => { root.selected = index }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: '#afafaf'
            }

            Repeater {
                model: sound.mode[root.selected]

                Item {
                    id: node

                    required property int index
                    required property PwNode modelData

                    Layout.fillWidth: true
                    Layout.preferredWidth: nodeColumn.implicitWidth
                    Layout.preferredHeight: nodeColumn.implicitHeight
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10

                    PwObjectTracker { 
                        objects: [node.modelData]
                        onObjectsChanged: {
                            node.modelData = sound.mode[root.selected][node.index]
                        }
                    }

                    ColumnLayout {
                        id: nodeColumn
                        anchors.fill: parent
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: `${node.modelData.description !== "" ? node.modelData.description : node.modelData.name}`
                                color: '#ffffff'
                                font.pixelSize: 14
                                font.bold: true
                            }

                            UI.Button {
                                source: {
                                    const isSink = node.modelData.isSink
                                    const muted = node.modelData.audio?.muted
                                    const volume = node.modelData.audio?.volume
                                    
                                    if (!isSink &&  muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone-slash-w.svg"))
                                    if ( isSink &&  muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-xmark-w.svg"))
                                    if (!isSink && !muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/microphone-w.svg"))
                                    if (volume > 0.66) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-2-w.svg"))
                                    if (volume > 0.33) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-1-w.svg"))
                                    return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-w.svg"))
                                }
                                onClicked: () => { node.modelData.audio.muted = !node.modelData.audio.muted }
                            }

                            UI.Button {
                                source: node.modelData === Pipewire.defaultAudioSink ? Qt.resolvedUrl(Quickshell.shellPath("Icons/emblem-default.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/emblem-default-2.svg"))
                                onClicked: () => { Pipewire.preferredDefaultAudioSink = node.modelData }
                                visible: root.selected === 2
                            }

                            UI.Button {
                                source: node.modelData === Pipewire.defaultAudioSource ? Qt.resolvedUrl(Quickshell.shellPath("Icons/emblem-default.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/emblem-default-2.svg"))
                                onClicked: () => { Pipewire.preferredDefaultAudioSource = node.modelData }
                                visible: root.selected === 3
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Item {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                implicitHeight: 4

                                UI.Slider {
                                    from: 0
                                    to: 1.5
                                    stepSize: 0.05
                                    snapMode: Slider.SnapOnRelease
                                    value: node.modelData.audio?.volume || 0
                                    onValueChanged: {
                                        if (node.modelData.audio) node.modelData.audio.volume = value
                                    }
                                }
                            }

                            Text { 
                                text: `${Math.round(node.modelData.audio?.volume * 100)}%`
                                color: '#ffffff'
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}