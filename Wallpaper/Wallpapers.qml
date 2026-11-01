pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import "UI" as UI
import "../services" as Services

PanelWindow {
    id: root

    visible: false
    focusable: false

    anchors.top: true
    margins.top: 50

    implicitWidth: 660
    implicitHeight: 180
    
    color: 'transparent'

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"

    exclusionMode: ExclusionMode.Ignore

    property Wallpaper currentWallpaper: null

    function toggle() {
        visible = !visible
        grab.active = visible
        
        if (!visible) return
        wallpaperList.getCurrentWallpaperModeAndIndex()
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onCleared: () => {
            root.visible = false
        }
    }

    Shortcut {
        sequence: "ESCAPE"
        onActivated: root.visible = false
    }

    Shortcut {
        sequence: "Up"
        onActivated: wallpaperList.currentIndex = Math.max(wallpaperList.currentIndex - 1, 0)
    }

    Shortcut {
        sequence: "Down"
        onActivated: wallpaperList.currentIndex = Math.min(wallpaperList.currentIndex + 1, wallpaperList.count - 1)
    }

    Shortcut {
        sequence: "Left"
        onActivated: wallpaperList.currentIndex = Math.max(wallpaperList.currentIndex - 1, 0)
    }

    Shortcut {
        sequence: "Right"
        onActivated: wallpaperList.currentIndex = Math.min(wallpaperList.currentIndex + 1, wallpaperList.count - 1)
    }

    Shortcut {
        sequence: "Return"
        onActivated: {
            if (wallpaperList.currentIndex < 0 || wallpaperList.currentIndex > wallpaperList.count - 1) return
            root.currentWallpaper.sourcePath = wallpaperList.currentItem.modelData.filePath
        }
    }

    Rectangle {
        id: body

        anchors.fill: parent

        radius: 8
        border.width: 1
        border.color: '#afafaf'
        color: "#272727"

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: wallpaperList.count + " wallpaper" + (wallpaperList.count !== 1 ? "s" : "")
                    color: '#828282'
                    font.pixelSize: 11
                }

                Item {
                    Layout.fillWidth: true
                }

                UI.Button {
                    text: "Image"
                    active: wallpaperList.mode === 0
                    onClicked: () => {
                        wallpaperList.mode = 0
                        wallpaperList.currentIndex = 0
                    }
                }

                UI.Button {
                    text: "Video"
                    active: wallpaperList.mode === 1
                    onClicked: () => {
                        wallpaperList.mode = 1
                        wallpaperList.currentIndex = 0
                    }
                }

                UI.Button {
                    text: "GIF"
                    active: wallpaperList.mode === 2
                    onClicked: () => {
                        wallpaperList.mode = 2
                        wallpaperList.currentIndex = 0
                    }
                }

                UI.Button {
                    text: "Random"
                    onClicked: () => {
                        const randomPath = Services.Wallpapers.getRandomFilePath()
                        if (randomPath.length > 0) root.currentWallpaper.sourcePath = randomPath
                        wallpaperList.getCurrentWallpaperModeAndIndex()
                    }
                }

                UI.Button {
                    text: "Clear"
                    onClicked: () => {
                        root.currentWallpaper.sourcePath = ""
                        wallpaperList.getCurrentWallpaperModeAndIndex()
                    }
                }
            }

            ListView {
                id: wallpaperList
                Layout.fillWidth: true
                Layout.fillHeight: true

                property int mode: 0 // 0 = wallpaper, 1 = live wallpaper, 2 = live gif wallpaper

                model: Services.Wallpapers.allWallpaperModel[mode]

                clip: true
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2000
                flickableDirection: Flickable.HorizontalFlick
                cacheBuffer: 0

                orientation: ListView.Horizontal
                layoutDirection: Qt.LeftToRight
                spacing: 12

                function getCurrentWallpaperModeAndIndex() {
                    const sorcePath = root.currentWallpaper.sourcePath

                    if (sorcePath === undefined || sorcePath.length === 0) {
                        mode = 0
                        wallpaperList.currentIndex = 0
                        wallpaperList.positionViewAtIndex(wallpaperList.currentIndex, ListView.Contain);
                        return
                    }

                    if (sorcePath.endsWith(".mp4") || sorcePath.endsWith(".mkv") || sorcePath.endsWith(".webm")) {
                        mode = 1
                    } else if (sorcePath.endsWith(".gif")) {
                        mode = 2
                    } else {
                        mode = 0
                    }

                    if (sorcePath.length > 0) {
                        for (let index = 0; index < Services.Wallpapers.allWallpaperModel[mode].count; index++) {
                            if (Services.Wallpapers.allWallpaperModel[mode].get(index, "filePath") === sorcePath) {
                                wallpaperList.currentIndex = index
                                wallpaperList.positionViewAtIndex(wallpaperList.currentIndex, ListView.Contain);
                                return
                            }
                        }
                    }
                        
                    wallpaperList.currentIndex = 0
                    wallpaperList.positionViewAtIndex(wallpaperList.currentIndex, ListView.Contain);
                }
    
                highlight: Rectangle {
                    radius: 8
                    color: '#1e1e1e'
                    visible: wallpaperList.currentIndex >= 0
                    border.width: 1
                    border.color: '#afafaf'
                }

                delegate: Rectangle {
                    id: delegateRoot
                    required property var modelData
                    required property int index

                    readonly property bool isCurrent:
                        wallpaperList.currentIndex === index

                    readonly property string filePath: modelData.filePath

                    readonly property bool isImage: /\.(png|jpe?g|webp)$/i.test(filePath)

                    readonly property bool isGif: filePath.endsWith(".gif")

                    readonly property bool isVideo: /\.(mp4|mkv|webm)$/i.test(filePath)

                    width: 200
                    height: wallpaperList.height
                    radius: 8

                    color: 'transparent'

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: wallpaperList.currentIndex = delegateRoot.index
                        onClicked: root.currentWallpaper.sourcePath = delegateRoot.modelData.filePath
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        visible: delegateRoot.isImage
                        source: delegateRoot.isImage ? delegateRoot.filePath : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        mipmap: false
                        sourceSize: Qt.size(256, 160)
                    }

                    AnimatedImage {
                        anchors.fill: parent
                        anchors.margins: 4
                        visible: delegateRoot.isGif
                        source: delegateRoot.isGif ? delegateRoot.filePath : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        playing: delegateRoot.isCurrent && visible
                        mipmap: false
                    }

                    VideoOutput {
                        id: video
                        anchors.fill: parent
                        anchors.margins: 4
                        visible: delegateRoot.isVideo && delegateRoot.isCurrent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }

                    MediaPlayer {
                        id: player
                        source: delegateRoot.isVideo && delegateRoot.isCurrent && root.visible ? delegateRoot.filePath : ""
                        videoOutput: video
                        audioOutput: AudioOutput {
                            muted: true
                            volume: 0.0
                        }
                        loops: MediaPlayer.Infinite

                        onSourceChanged: {
                            if (source.toString().length > 0)
                                play()
                            else
                                stop()
                        }

                        onErrorOccurred: function(error, errorString) {
                            console.warn("Wallpaper video error:", errorString)
                        }
                    }
                }
            }
        }
    }
}