pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string input: ""

    readonly property ScriptModel filteredApps: ScriptModel {
        objectProp: "id"
        values: {
        const all = [...DesktopEntries.applications.values];
        const q = root.input.trim().toLowerCase();
        if (q === "") {
            return all.sort((a, b) => {
                const ac = root.count(a)
                const bc = root.count(b)

                if (ac !== bc) return bc - ac
                return a.name.localeCompare(b.name)
            });
        }
        return all.filter(d =>
                (d.name && d.name.toLowerCase().includes(q)) ||
                (d.genericName && d.genericName.toLowerCase().includes(q)) ||
                (d.keywords && d.keywords.some(k => k.toLowerCase().includes(q))) ||
                (d.categories && d.categories.some(c => c.toLowerCase().includes(q)))
            ).sort((a, b) => {
                const an = a.name.toLowerCase();
                const bn = b.name.toLowerCase();
                const aStarts = an.startsWith(q);
                const bStarts = bn.startsWith(q);
                if (aStarts && !bStarts) return -1;
                if (!aStarts && bStarts) return 1;
                return an.localeCompare(bn);
            });
        }
    }

    readonly property FileView launchStatsFile: FileView {
        path: Quickshell.cachePath("launch-counts.json")

        watchChanges: true
        onFileChanged: reload()

        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property var counts: ({})
        }
    }

    function count(app) {
        if (!app || !app.id)
            return 0

        return adapter.counts[app.id] ?? 0
    }

    function increment(app) {
        if (!app || !app.id)
            return

        const next = Object.assign({}, adapter.counts)
        next[app.id] = (next[app.id] ?? 0) + 1

        adapter.counts = next
    }

    function reset(app) {
        if (!app || !app.id)
            return

        const next = Object.assign({}, adapter.counts)
        delete next[app.id]

        adapter.counts = next
    }

    function clear() {
        adapter.counts = ({})
    }
}