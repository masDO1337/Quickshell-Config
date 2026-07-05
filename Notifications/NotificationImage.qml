import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root

    property bool isImage: false
    property bool isAppIcon: false

    property string image : ""
    property string appIcon : ""
    
    Layout.preferredWidth: i.implicitWidth
    Layout.preferredHeight: i.implicitHeight
    color: 'transparent'
    radius: 6
    visible: isImage || (isAppIcon && appIcon !== "")

    IconImage {
        id: i
        anchors.centerIn: parent
        implicitSize: 64
        source: root.isImage ? Qt.resolvedUrl(root.image ?? "") : Qt.resolvedUrl(root.appIcon)
    }
}