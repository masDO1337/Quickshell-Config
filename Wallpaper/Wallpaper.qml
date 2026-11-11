import Quickshell
import Quickshell.Wayland
import QtQuick
import QtMultimedia
import "../services" as Services

PanelWindow {
    id: root

    color: "#101018"
    focusable: false
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-wallpaper"

    // global wallpaper source path, can be set by the user or randomly selected from the wallpapers directory.
    property string sourcePath: { const path = Services.Wallpapers.get(root.screen.name); return path; }

    readonly property bool isImage: /\.(png|jpe?g|webp)$/i.test(sourcePath)
    readonly property bool isGif: sourcePath.endsWith(".gif")
    readonly property bool isVideo: /\.(mp4|mkv|webm)$/i.test(sourcePath)
    readonly property bool isShader: sourcePath.endsWith(".qsb")

    // Static image
    Image {
        id: staticImage
        anchors.fill: parent
        visible: root.isImage
        source: root.isImage ? root.sourcePath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        mipmap: false
    }

    // Animated GIF
    AnimatedImage {
        id: animatedImage
        anchors.fill: parent
        visible: root.isGif
        source: root.isGif ? root.sourcePath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        playing: root.isGif
        mipmap: false
    }

    VideoOutput {
        id: video
        anchors.fill: parent
        visible: root.isVideo
        fillMode: VideoOutput.PreserveAspectCrop
    }

    MediaPlayer {
        id: player
        source: root.isVideo ? root.sourcePath : ""
        videoOutput: video
        audioOutput: AudioOutput {
            muted: true
            volume: 0.0
        }
        loops: MediaPlayer.Infinite

        onErrorOccurred: function(error, errorString) {
            console.warn("Wallpaper video error:", errorString)
        }

        onSourceChanged: {
            if (root.isVideo && source.toString().length > 0)
                play()
            else
                stop()
        }
    }

    // Procedural GLSL wallpaper.
    // ShaderEffect requires a Qt Shader Baker (.qsb) file, not raw .frag GLSL.
    ShaderEffect {
        id: shader
        anchors.fill: parent
        visible: root.sourcePath === "" || root.isShader

        property real time: 0.0
        property vector2d resolution: Qt.vector2d(width, height)

        fragmentShader: root.isShader ? root.sourcePath : Qt.resolvedUrl("shaders/ambient.frag.qsb")
    }

    FrameAnimation {
        running: root.sourcePath === "" || root.isShader
        onTriggered: shader.time = elapsedTime
    }
}