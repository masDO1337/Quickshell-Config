import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services" as Services

PanelWindow {
    id: root
    
    visible: false

    anchors {
        right: true
        left: true
        top: true
        bottom: true
    }
    
    color: 'transparent'

    WlrLayershell.namespace: "quickshell-screenshot"
    exclusionMode: ExclusionMode.Ignore  
    WlrLayershell.layer: WlrLayer.Overlay  
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property HyprlandMonitor monitor: Hyprland.focusedMonitor
    property HyprlandWorkspace workspace: monitor?.activeWorkspace
    property ObjectModel windows: workspace?.toplevels ?? []

    property point startPos
    property vector4d target: Qt.vector4d(0, 0, 0, 0)
    property bool windowMode: false

    function toggle() {
        if (Services.Screenshot.running) return
        if (!visible) {
            Services.Screenshot.start(screen)
            Hyprland.refreshToplevels()
            screencopy.captureFrame()
            target = Qt.vector4d(0, 0, 0, 0)
        }

        visible = !visible
        grab.active = visible
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onCleared: {
            root.visible = false
            Services.Screenshot.cancel()
        }
    }

    Shortcut {
        sequence: "ESCAPE"
        onActivated: {
            root.visible = false
            Services.Screenshot.cancel()
        }
    }

    ScreencopyView {
        id: screencopy
        anchors.fill: parent
        captureSource: root.screen
        paintCursor: false
    }

    // Shader overlay  
    ShaderEffect {  
        anchors.fill: parent
        
        property vector4d selectionRect: root.target
        property real dimOpacity: 0.5  
        property vector2d screenSize: Qt.vector2d(root.width, root.height)  
        property real borderRadius: 8.0
        property real outlineThickness: 1.0  
        
        fragmentShader: Qt.resolvedUrl("shaders/dimming.frag.qsb") 
    }

    MouseArea {  
        id: mouseArea  
        anchors.fill: parent
        
        onPressed: (mouse) => {
            root.startPos = Qt.point(mouse.x, mouse.y)
            if (!root.windowMode) {
                root.target = Qt.vector4d(0, 0, 0, 0)
                return
            }
            if (
                mouse.x <= root.target.x || 
                mouse.x >= root.target.x + root.target.z || 
                mouse.y <= root.target.y ||
                mouse.y >= root.target.y + root.target.w
            ) {
                root.windowMode = false
                root.target = Qt.vector4d(0, 0, 0, 0)
            }
        }  
        
        onPositionChanged: (mouse) => {  
            if (pressed) {  
                const x = Math.min(root.startPos.x, mouse.x)  
                const y = Math.min(root.startPos.y, mouse.y)  
                const width = Math.abs(mouse.x - root.startPos.x)  
                const height = Math.abs(mouse.y - root.startPos.y)  
                
                root.target = Qt.vector4d(Math.round(x), Math.round(y), Math.round(width), Math.round(height)) 
            }  
        }

        onReleased: (mouse) => {
            if (root.target.z === 0 || root.target.w === 0) {
                root.windows.values.forEach(window => {
                    const monitorX = root.monitor.lastIpcObject.x
                    const monitorY = root.monitor.lastIpcObject.y

                    const x = window.lastIpcObject.at[0] - monitorX
                    const y = window.lastIpcObject.at[1] - monitorY
                    
                    const width = window.lastIpcObject.size[0]
                    const height = window.lastIpcObject.size[1]

                    if (
                        mouse.x >= x && 
                        mouse.x <= x + width && 
                        mouse.y >= y && 
                        mouse.y <= y + height
                    ) {
                        root.target = Qt.vector4d(x, y, width, height)
                        root.windowMode = true
                    }
                })
            } else {
                Services.Screenshot.processScreenshot(root.target, () => {
                    root.visible = false
                    Services.Screenshot.cancel()
                })
            }
        }
    }
}