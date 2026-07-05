import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property alias text: input.text
    property var echoMode: TextInput.Normal
    property string inputPrompt: "Input"
    property var onReturnPressed: null

    Layout.fillWidth: true
    Layout.preferredHeight: row.implicitHeight + 20
    radius: 10
    color: 'transparent'
    border.color: input.activeFocus ? '#3a3a3a' : 'transparent'
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        Text {
            text: root.inputPrompt
            color: "#FFF"
            font.pixelSize: 16
        }

        TextInput {
            id: input
            Layout.fillWidth: true
            color: "#fff"
            font.pixelSize: 16
            echoMode: root.echoMode
            clip: true
            focus: true

            Text {
                anchors.fill: parent
                text: "Type..."
                color: '#828282'
                font.pixelSize: 16
                visible: !parent.text
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onReturnPressed: root.onReturnPressed()
        }
    }
}