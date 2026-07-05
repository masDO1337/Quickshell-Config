import Quickshell // for PanelWindow
import QtQuick.Layouts
import QtQuick // for Text
import "Blocks" as Blocks

PanelWindow {
    id: bar

    property alias appLauncher: appLauncher
    property alias notifications: notifications
    property alias powerMenu: powerMenu
    property alias sound: sound

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30
    color: "#272727"

    margins.top: -implicitWidth

    SequentialAnimation {
        running: true
        PauseAnimation { duration: 50 }
        NumberAnimation {
            target: bar
            property: "margins.top"
            to: 0
            duration: 360
        }
    }

    RowLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 8
        spacing: 4
        
        Blocks.AppLauncher { id: appLauncher }
        Blocks.Clock {}
        Blocks.Updates {}
        Blocks.Workspaces {}
    }

    RowLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Blocks.MprisPlayer {}
        Blocks.ActiveWorkspace {}
        Blocks.Notifications { id: notifications }
    }

    RowLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 4
        
        Blocks.ServerStatus {}
        Blocks.SystemTray {}
        Blocks.Network {}
        Blocks.Bluetooth {}
        Blocks.Sound { id: sound }
        Blocks.PowerMenu { id: powerMenu }
    }
}