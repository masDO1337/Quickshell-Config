pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property ObjectModel players: Mpris.players

    readonly property MprisPlayer activePlayer: {
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const player = Mpris.players.values[i]

            if (player.isPlaying)
                return player
        }

        return Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null
    }

    property bool isPlayer: players.values.length > 0
    property bool isPlaying: isPlayer && activePlayer.isPlaying
    

    function toggle() {
        if (activePlayer?.canTogglePlaying)
            activePlayer.togglePlaying()
    }

    function next() {
        if (activePlayer?.canGoNext)
            activePlayer.next()
    }

    function previous() {
        if (activePlayer?.canGoPrevious)
            activePlayer.previous()
    }
}