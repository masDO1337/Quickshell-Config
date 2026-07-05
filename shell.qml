//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "Bar"
import "AppLauncher"
import "Notifications"
import "PowerMenu"
import "Polkit"

ShellRoot {
    id: root

    property list<Bar> bar: []
    property list<PowerMenu> powerMenu: []
    property list<AppLauncher> appLauncher: []
    
    function toggle(list) {
        for (let item of list) {
            if (Hyprland.focusedMonitor == Hyprland.monitorFor(item.screen)) item.toggle()     
        }
    }

    IpcHandler {
        target: "toggle"
        function power() { root.toggle(root.powerMenu) }
        function launcher() { root.toggle(root.appLauncher) }
        function sound() { 
            for (let item of root.bar) {
                if (Hyprland.focusedMonitor == Hyprland.monitorFor(item.screen)) item.sound.toggle()     
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: scope
            property ShellScreen modelData

            Polkit { screen: scope.modelData }

            Bar {
                id: bar 
                screen: scope.modelData
                Component.onCompleted: root.bar.push(bar)
            }

            Notifications {
                id: notifications
                screen: scope.modelData

                Connections {
                    target: bar.notifications
                    function onToggle() { notifications.toggle() }
                }
            }

            AppLauncher {
                id: appLauncher
                screen: scope.modelData
                Component.onCompleted: root.appLauncher.push(appLauncher)

                Connections {
                    target: bar.appLauncher
                    function onToggle() { appLauncher.toggle() }
                }
            }

            PowerMenu {
                id: powerMenu
                screen: scope.modelData
                Component.onCompleted: root.powerMenu.push(powerMenu)

                Connections {
                    target: bar.powerMenu
                    function onToggle() { powerMenu.toggle() }
                }
            }
        }
    }
}
