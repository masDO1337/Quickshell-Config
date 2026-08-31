import QtQuick
import QtQuick.Layouts
import QtQuick.VectorImage

Rectangle {
    id: root

    property bool on: m.containsMouse
    property string text: "Button"
    property url source: undefined
    property var onClicked: () => {}
    property var onEntered: (index) => {}

    property alias mouse: m

    Layout.fillWidth: !on
    implicitWidth: row.implicitWidth + 13
    implicitHeight: row.implicitHeight + 13
    radius: 8
    color: on ? '#7f7f7f' : "#1e1e1e"

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        VectorImage {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            preferredRendererType: VectorImage.CurveRenderer
            source: root.source
        }

        Text {
            text: root.text
            color: "#fff"
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
            visible: root.on
        }
    }

    MouseArea {
        id: m
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.onClicked()
        onEntered: root.onEntered(root.index)
    }
}