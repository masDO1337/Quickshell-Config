pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpaper"

    property FolderListModel wallpaperModel: FolderListModel {
        folder: Qt.resolvedUrl(root.wallpaperDir)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
    }

    property FolderListModel liveWallpaperModel: FolderListModel {
        folder: Qt.resolvedUrl(root.wallpaperDir)
        nameFilters: ["*.mp4", "*.mkv", "*.webm"]
    }

    property FolderListModel liveGifWallpaperModel: FolderListModel {
        folder: Qt.resolvedUrl(root.wallpaperDir)
        nameFilters: ["*.gif"]
    }

    property FolderListModel shaderWallpaperModel: FolderListModel {
        folder: Qt.resolvedUrl(root.wallpaperDir)
        nameFilters: ["*.qsb"]
    }

    property list<FolderListModel> allWallpaperModel: [wallpaperModel, liveWallpaperModel, liveGifWallpaperModel, shaderWallpaperModel]

    property var screens: ({})

    readonly property FileView screensStatusFile: FileView {
        path: Quickshell.cachePath("screens-status.json")

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: {
            if (adapter.screens === undefined) {
                adapter.screens = {}
                writeAdapter()
            }
            root.screens = Object.assign({}, adapter.screens)
        }

        JsonAdapter {
            id: adapter
            property var screens: ({})
        }
    }

    function get(name) {
        if (screens.hasOwnProperty(name) === false) return ""
        const path = screens[name].path === "" ? getRandomFilePath() : screens[name].path
        return path
    }

    function save(name, path) {
        if (screens.hasOwnProperty(name) === false) {
            screens[name] = { path: path }
        } else {
            screens[name].path = path
        }
        adapter.screens = Object.assign({}, screens)
    }

    function isRandom(name) : bool {
        const s = Object.assign({}, adapter.screens)
        if (s.hasOwnProperty(name) === false) return true
        return s[name].path === "" ? true : false
    }

    function getRandomFilePath() {

        if (wallpaperModel.count === 0)
            return ""

        const index = Math.floor(Math.random() * wallpaperModel.count)
        const path = wallpaperModel.get(index, "filePath")

        return path !== undefined ? path.toString() : ""
    }
}