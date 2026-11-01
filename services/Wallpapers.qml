pragma Singleton

import QtQuick
import Quickshell
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

    property list<FolderListModel> allWallpaperModel: [wallpaperModel, liveWallpaperModel, liveGifWallpaperModel]

    function getRandomFilePath() {

        if (wallpaperModel.count === 0)
            return ""

        const index = Math.floor(Math.random() * wallpaperModel.count)
        const path = wallpaperModel.get(index, "filePath")

        return path !== undefined ? path.toString() : ""
    }
}