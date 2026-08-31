import QtQuick
import QtQuick.Layouts
import QtQuick.VectorImage

Rectangle {
    id: root

    property bool showText: true
    property bool showIcon: false

    property url source: ""
    property int iconSize: 16

    property string text: "Button"

    property alias mouse: m
    property var onClicked: () => {}

    implicitWidth: row.implicitWidth + 13
    implicitHeight: row.implicitHeight + 13
    radius: 8
    color: m.containsMouse ? '#487f7f7f' : '#00ffffff'

    Behavior on color {
        ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        VectorImage {
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            preferredRendererType: VectorImage.CurveRenderer
            source: root.source
            visible: root.showIcon
        }

        Text {
            text: root.text
            color: "#828282"
            font.pixelSize: 11
            font.bold: true
            elide: Text.ElideRight
            visible: root.showText
        }
    }

    MouseArea {
        id: m
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.onClicked()
    }
}