import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "symbols.js" as Symbols

// App launcher (replaces wofi; same look). Open with:  qs ipc call launcher toggle
//   type          -> search apps (Enter launches, Space expands desktop actions)
//   ">" + query   -> symbol picker (6-wide grid, arrows + Enter/click copies)
//   Esc / click outside closes
Scope {
    id: launcher
    property bool open: false
    property string query: ""
    property int sel: 0
    property string expanded: ""            // desktop-entry id whose actions are shown
    property int flashed: -1                 // symbol cell flashing green after copy

    readonly property bool symbolMode: query.startsWith(">")
    readonly property string font: "BlexMono Nerd Font"

    function toggle() {
        if (open) { open = false; return; }
        query = ""; sel = 0; expanded = ""; flashed = -1;
        open = true;
    }
    onQueryChanged: { sel = 0; expanded = ""; }

    // ---------- apps ----------
    function appScore(e, q) {
        const name = (e.name || "").toLowerCase();
        if (name.startsWith(q)) return 4;
        if (name.split(/[\s\-_.]+/).some(w => w.startsWith(q))) return 3;
        if (name.includes(q)) return 2;
        const extra = [e.genericName || "", (e.keywords || []).join(" "), e.id || ""].join(" ").toLowerCase();
        return extra.includes(q) ? 1 : 0;
    }

    readonly property var apps: {
        if (symbolMode) return [];
        const q = query.trim().toLowerCase();
        const all = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        const scored = all.map(e => ({ e: e, s: q === "" ? 1 : appScore(e, q) })).filter(x => x.s > 0);
        scored.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        return scored.map(x => x.e);
    }

    // apps + expanded action sub-rows: { entry, action }
    readonly property var appRows: {
        const rows = [];
        for (const e of apps) {
            rows.push({ entry: e, action: null });
            if (e.id === expanded) for (const a of (e.actions || [])) rows.push({ entry: e, action: a });
        }
        return rows;
    }

    // ---------- symbols ----------
    // precomputed once: words of name + aliases
    readonly property var symIndex: Symbols.list.map((s, i) => ({
        ch: s[0], name: s[1], i: i,
        words: (s[1] + " " + s[2]).toLowerCase().split(/[\s\-]+/).filter(w => w !== "")
    }))

    readonly property var symbols: {
        if (!symbolMode) return [];
        const q = query.slice(1).trim().toLowerCase();
        if (q === "") return symIndex;
        const qwords = q.split(/\s+/);
        const res = [];
        for (const s of symIndex) {
            let score = 0;
            if (q.includes(s.ch.toLowerCase()) && !/^[a-z0-9 ]+$/.test(q)) score = 100;   // typed the char itself
            else {
                for (const w of qwords) {
                    let best = 0;
                    for (const sw of s.words) {
                        if (sw === w) { best = 2; break; }
                        if (sw.startsWith(w)) best = 1;
                    }
                    if (best === 0) { score = 0; break; }
                    score += best;
                }
            }
            if (score > 0) res.push({ s: s, score: score });
        }
        res.sort((a, b) => b.score - a.score || a.s.i - b.s.i);
        return res.map(x => x.s);
    }

    readonly property int count: symbolMode ? symbols.length : appRows.length

    function activate(i) {
        if (i < 0 || i >= count) return;
        if (symbolMode) {
            Quickshell.execDetached(["wl-copy", "--", symbols[i].ch]);
            flashed = i;
            closeAfterFlash.restart();
        } else {
            const r = appRows[i];
            open = false;
            r.action ? r.action.execute() : r.entry.execute();
        }
    }

    Timer {
        id: closeAfterFlash
        interval: 140
        onTriggered: { launcher.open = false; launcher.flashed = -1; }
    }

    PanelWindow {
        visible: launcher.open
        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name)
            ?? Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-launcher"
        color: Qt.rgba(16 / 255, 16 / 255, 16 / 255, 0.75)

        MouseArea {
            anchors.fill: parent
            onClicked: launcher.open = false
        }

        Rectangle {
            id: box
            anchors.centerIn: parent
            width: 500
            height: 400
            color: Theme.bg
            border.color: "#101010"
            border.width: 2

            MouseArea { anchors.fill: parent }    // clicks inside don't close

            // ---- input ----
            Rectangle {
                id: inputBox
                x: 12; y: 12
                width: parent.width - 24
                height: 30
                color: input.activeFocus ? "transparent" : "#101010"
                border.color: Theme.fg
                border.width: input.activeFocus ? 1 : 0

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: modeTag.visible ? modeTag.width + 12 : 6
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fg
                    selectionColor: Theme.fg
                    selectedTextColor: Theme.bg
                    font.family: launcher.font
                    font.pixelSize: 14
                    clip: true
                    focus: launcher.open
                    text: launcher.query
                    onTextChanged: if (text !== launcher.query) launcher.query = text
                    onVisibleChanged: if (visible) forceActiveFocus()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Search...   ( > symbols )"
                        color: Theme.dim
                        font: input.font
                    }

                    Keys.onPressed: event => {
                        const k = event.key;
                        const sym = launcher.symbolMode;
                        const cols = 6;
                        const n = launcher.count;
                        const move = d => { launcher.sel = Math.max(0, Math.min(n - 1, launcher.sel + d)); };
                        if (k === Qt.Key_Escape) launcher.open = false;
                        else if (k === Qt.Key_Return || k === Qt.Key_Enter) launcher.activate(launcher.sel);
                        else if (k === Qt.Key_Down || (k === Qt.Key_Tab && !sym)) move(sym ? cols : 1);
                        else if (k === Qt.Key_Up || (k === Qt.Key_Backtab && !sym)) move(sym ? -cols : -1);
                        else if (sym && k === Qt.Key_Right) move(1);
                        else if (sym && k === Qt.Key_Left) move(-1);
                        else if (!sym && k === Qt.Key_Space && n > 0) {
                            const r = launcher.appRows[launcher.sel];
                            if (!r || !(r.entry.actions || []).length) return;   // types a space
                            launcher.expanded = launcher.expanded === r.entry.id ? "" : r.entry.id;
                            launcher.sel = launcher.appRows.findIndex(x => x.entry.id === r.entry.id && !x.action);
                        }
                        else return;
                        event.accepted = true;
                    }
                }

                Text {
                    id: modeTag
                    visible: launcher.symbolMode
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "SYMBOLS · " + launcher.symbols.length
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                    font.weight: Font.Bold
                }
            }

            // ---- app list (wofi look) ----
            ListView {
                id: appList
                visible: !launcher.symbolMode
                x: 12; y: inputBox.y + inputBox.height + 8
                width: parent.width - 24
                height: parent.height - y - 12
                clip: true
                model: launcher.appRows
                currentIndex: launcher.sel
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: appRow
                    required property var modelData
                    required property int index
                    readonly property bool isAction: modelData.action !== null
                    readonly property bool active: launcher.sel === index
                    width: appList.width - (isAction ? 10 : 0)
                    x: isAction ? 5 : 0
                    height: 24
                    color: active && !isAction ? Theme.fg : isAction ? "#101010" : "transparent"
                    border.color: Theme.fg
                    border.width: active && isAction ? 1 : 0

                    Text {
                        x: appRow.isAction ? 14 : 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x - 4
                        elide: Text.ElideRight
                        text: appRow.isAction ? appRow.modelData.action.name : appRow.modelData.entry.name
                        color: appRow.active && !appRow.isAction ? "#101010" : Theme.fg
                        font.family: launcher.font
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: launcher.sel = appRow.index
                        onClicked: launcher.activate(appRow.index)
                    }
                }
            }

            // ---- symbol grid ----
            GridView {
                id: symGrid
                visible: launcher.symbolMode
                x: 12; y: inputBox.y + inputBox.height + 10
                width: parent.width - 24
                height: parent.height - y - 12
                clip: true
                cellWidth: width / 6
                cellHeight: cellWidth
                model: launcher.symbols
                currentIndex: launcher.sel
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: cellItem
                    required property var modelData
                    required property int index
                    readonly property bool active: launcher.sel === index
                    readonly property bool flash: launcher.flashed === index
                    width: symGrid.cellWidth
                    height: symGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        color: cellItem.flash ? Theme.green : cellItem.active ? Theme.fg : Theme.panel

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -4
                            text: cellItem.modelData.ch
                            color: cellItem.active || cellItem.flash ? "black" : Theme.fg
                            font.family: launcher.font
                            font.pixelSize: 24
                        }
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 8
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: cellItem.modelData.name.toUpperCase()
                            color: cellItem.active || cellItem.flash ? "#3a3a3a" : Theme.dim
                            font.family: Theme.font
                            font.pixelSize: 7
                            font.letterSpacing: 0.5
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: launcher.sel = cellItem.index
                            onClicked: launcher.activate(cellItem.index)
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: launcher.count === 0
                text: launcher.symbolMode ? "NO SYMBOLS" : "NO APPS"
                color: Theme.dim
                font.family: Theme.font
                font.pixelSize: 11
                font.letterSpacing: 1.5
            }
        }
    }
}
