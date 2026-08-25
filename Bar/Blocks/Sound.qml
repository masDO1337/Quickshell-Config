import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../PopupWindows"
import "UI" as UI

Item {
    id: root

    function toggle() {
        soundPanel.toggle()
    }

    Layout.fillHeight: true
    Layout.preferredWidth: box.implicitWidth

    property PwNode sink: Pipewire.defaultAudioSink

    PwObjectTracker { 
        objects: [Pipewire.defaultAudioSink]
        onObjectsChanged: {
            root.sink = Pipewire.defaultAudioSink
        }
    }

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: {
            const muted = root.sink?.audio?.muted
            const volume = root.sink?.audio?.volume;
            
            if (muted) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-xmark.svg"))
            if (volume > 0.66) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-2.svg"))
            if (volume > 0.33) return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker-wave-1.svg"))
            return Qt.resolvedUrl(Quickshell.shellPath("Icons/speaker.svg"))
        }

        text: `${Math.round(root.sink?.audio?.volume * 100)}%`
        textColor: "#a6e1f3"

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                soundPanel.toggle()
            }
            if (mouse.button === Qt.MiddleButton) {
                pavucontrol.running = true
            }
            if (mouse.button === Qt.RightButton) {
                root.sink.audio.muted = !root.sink.audio.muted
            }
        }
        onWheel: (event) => {
            if (root.sink?.audio) {
                root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + (event.angleDelta.y / 120) * 0.05))
            }
        }
    }

    Process {
        id: pavucontrol
        command: ["pavucontrol"]
        running: false
    }

    SoundPanel {
        id: soundPanel
        parentItem: root
    }
}