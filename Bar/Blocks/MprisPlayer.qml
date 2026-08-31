import Quickshell
import QtQuick
import QtQuick.Layouts
import "../PopupWindows"
import "../../services" as Services
import "UI" as UI

Item {
    id: root
    Layout.fillHeight: true
    implicitWidth: box.implicitWidth
    visible: Services.MprisPlayer.isPlayer

    UI.Button {
        id: box
        anchors.centerIn: parent

        source: Services.MprisPlayer.isPlaying ? Qt.resolvedUrl(Quickshell.shellPath("Icons/play-pause.svg")) : Qt.resolvedUrl(Quickshell.shellPath("Icons/component.svg"))

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (event) => {
            if (event.button == Qt.LeftButton) {
                Services.MprisPlayer.toggle()
            } 
            if (event.button == Qt.RightButton) {
                mprisPlayerPanel.toggle()
            }
        }
    }

    Tooltip {
        parentItem: root
        hover: box.mouse.containsMouse && Services.MprisPlayer.isPlaying

        Item {
            anchors.fill: parent
            implicitWidth: t.implicitWidth + 20
            implicitHeight: t.implicitHeight + 20
            
            Text {
                id: t
                anchors.centerIn: parent
                text: `${Services.MprisPlayer.activePlayer.trackTitle || "Unknown Title"} - ${Services.MprisPlayer.activePlayer.trackArtist || "Unknown Artist"}`
                elide: Text.ElideRight
                color: "white"
                font.pixelSize: 12
            }
        }
    }

    MprisPlayerPanel {
        id: mprisPlayerPanel
        parentItem: root
    }
}