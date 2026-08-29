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
import "Screenshot"

ShellRoot {
    id: root

    property list<Bar> bar: []
    property list<PowerMenu> powerMenu: []
    property list<AppLauncher> appLauncher: []
    property list<Screenshot> screenshot: []

    function remove(list, item) {
        const index = list.indexOf(item)
        if (index !== -1) list.splice(index, 1)
    }
    
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
        function screenshot() { root.toggle(root.screenshot) }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: scope
            property ShellScreen modelData

            Polkit { screen: scope.modelData }

            Notifications { screen: scope.modelData }

            Bar {
                id: bar 
                screen: scope.modelData
                Component.onCompleted: root.bar.push(bar)
                Component.onDestruction: root.remove(root.bar, bar)
            }

            AppLauncher {
                id: appLauncher
                screen: scope.modelData
                Component.onCompleted: root.appLauncher.push(appLauncher)
                Component.onDestruction: root.remove(root.appLauncher, appLauncher)

                Connections {
                    target: bar.appLauncher
                    function onToggle() { appLauncher.toggle() }
                }
            }

            Screenshot {
                id: screenshot
                screen: scope.modelData
                Component.onCompleted: root.screenshot.push(screenshot)
                Component.onDestruction: root.remove(root.screenshot, screenshot)
            }

            PowerMenu {
                id: powerMenu
                screen: scope.modelData
                Component.onCompleted: root.powerMenu.push(powerMenu)
                Component.onDestruction: root.remove(root.powerMenu, powerMenu)

                Connections {
                    target: bar.powerMenu
                    function onToggle() { powerMenu.toggle() }
                }
            }
        }
    }
}
