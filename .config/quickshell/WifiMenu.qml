import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Saved wifi profiles only (no scanning).
ColumnLayout {
    id: menu
    spacing: 2

    property var nets: []          // [{ name, uuid, active }]
    property string connecting: "" // uuid being activated
    property string failed: ""     // uuid of last failed attempt

    // nmcli -t escapes ':' and '\' with a backslash
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) { cur += line[++i]; }
            else if (c === ":") { out.push(cur); cur = ""; }
            else cur += c;
        }
        out.push(cur);
        return out;
    }

    function refresh() { listProc.running = true; }

    function connectTo(uuid) {
        if (upProc.running) return;
        failed = "";
        connecting = uuid;
        upProc.uuid = uuid;
        upProc.running = true;
    }

    Process {
        id: listProc
        running: true
        command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,ACTIVE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    const f = menu.splitTerse(line);
                    if (f.length < 4 || f[2] !== "802-11-wireless") continue;
                    out.push({ name: f[0], uuid: f[1], active: f[3] === "yes" });
                }
                out.sort((a, b) => (b.active - a.active) || a.name.localeCompare(b.name));
                menu.nets = out;
            }
        }
    }

    Process {
        id: upProc
        property string uuid: ""
        command: ["nmcli", "connection", "up", "uuid", uuid]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) menu.failed = uuid;
            menu.connecting = "";
            menu.refresh();
        }
    }

    Repeater {
        model: menu.nets
        ListRow {
            required property var modelData
            Layout.fillWidth: true
            icon: "" // wifi
            label: modelData.name
            active: modelData.active
            sublabel: menu.connecting === modelData.uuid ? "Connecting…"
                    : menu.failed === modelData.uuid ? "Failed" : ""
            onClicked: if (!modelData.active) menu.connectTo(modelData.uuid)
        }
    }

    StyledText {
        visible: menu.nets.length === 0
        text: "No saved networks"
        color: Theme.dim
        Layout.leftMargin: 6
    }
}
