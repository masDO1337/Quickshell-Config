import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services" as Services

PanelWindow {
    id: root
    
    visible: Services.Polkit.visible
    focusable: true

    anchors {
        right: true
        left: true
        top: true
        bottom: true
    }
    
    color: '#50000000'

    WlrLayershell.namespace: "quickshell-polkit-agent"

    Rectangle {
        id: body
        
        anchors.centerIn: parent
        implicitWidth: Math.max(content.implicitWidth + 20, 460)
        implicitHeight: content.implicitHeight + 20

        visible: (Hyprland.focusedMonitor === Hyprland.monitorFor(root.screen))

        Behavior on implicitWidth {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        radius: 8
        border.width: 1
        border.color: '#afafaf'
        color: "#272727"

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                IconImage {
                    implicitSize: 32
                    source: Qt.resolvedUrl(Services.Polkit.iconName)
                    visible: Services.Polkit.iconName !== ""
                }

                Text {
                    text: Services.Polkit.title
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: "#fff"
                font.pixelSize: 14
                text: Services.Polkit.message
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: Services.Polkit.supplementaryIsError ? "#f38ba8" : '#828282'
                text: Services.Polkit.supplementaryMessage
                font.pixelSize: 14
                visible: text.length > 0
            }

            Text {
                visible: Services.Polkit.responseRequired && Services.Polkit.failed
                text: "Authentication failed, try again"
                color: "#ff6666"
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Repeater {
                model: Services.Polkit.inputs

                InputBox {
                    id: input
                    required property var modelData

                    Layout.fillWidth: true
                    visible: Services.Polkit.responseRequired
                    inputPrompt: modelData.prompt ?? ""
                    echoMode: modelData.isPassword ?? false
                        ? TextInput.Password
                        : TextInput.Normal

                    text: modelData.value ?? ""
                    inputFocus: modelData.focus ?? false
                    onInputFocusChanged: {
                        modelData.focus = inputFocus
                    }
                    onTextChanged: {
                        modelData.value = text
                    }

                    onReturnPressed: () => {
                        Services.Polkit.submit(text)
                        text = ""
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                ButtonBox {
                    text: "Cancel"
                    onClicked: () => {
                        Services.Polkit.cancel()
                    }
                }

                ButtonBox {
                    text: Services.Polkit.acceptText
                    visible: Services.Polkit.responseRequired
                    onClicked: () => {
                        Services.Polkit.submit("")
                    }
                }
            }
        }
    }
}
