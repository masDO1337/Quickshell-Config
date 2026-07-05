import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property alias text: searchInput.text
    property var onPressed: null

    Layout.fillWidth: true
    height: 44
    radius: 10
    color: 'transparent'
    border.color: searchInput.activeFocus ? '#3a3a3a' : 'transparent'
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
            text: "App"
            color: "#FFF"
            font.pixelSize: 16
            //font.family: root.font
            Layout.alignment: Qt.AlignVCenter
        }

        TextInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: "#fff"
            font.pixelSize: 15
            //font.family: root.font
            clip: true
            focus: true
            Accessible.role: Accessible.EditableText
            Accessible.name: "Search applications"

            Text {
                anchors.fill: parent
                text: "Type to search..."
                color: '#828282'
                font: parent.font
                visible: !parent.text
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onPressed: event => {root.onPressed(event)}
        }
    }
}