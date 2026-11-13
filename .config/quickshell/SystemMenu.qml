import QtQuick
import Quickshell.Io

// Overlay under the battery item. 4x4 grid of cells:
//    0  1  2  3
//    4  5  6  7     battery (0-7)
//    8  9 10 11     cpu (8-9)   temp (10-11)
//   12 13 14 15     ram (12-13) disk (14-15)
Item {
    id: menu
    readonly property int cellW: 82
    readonly property int cellH: 64
    readonly property int gap: 6
    function spanW(n) { return n * cellW + (n - 1) * gap; }
    function spanH(n) { return n * cellH + (n - 1) * gap; }
    function cellX(i) { return (i % 4) * (cellW + gap); }
    function cellY(i) { return Math.floor(i / 4) * (cellH + gap); }

    implicitWidth: spanW(4)
    implicitHeight: spanH(4)
    width: implicitWidth
    height: implicitHeight

    // ---- stats (refreshed every 2 s while the overlay is open) ----
    property real cpu: -1
    property var lastCpu: null          // [busy, total]
    property real memUsed: 0            // bytes
    property real memTotal: 0
    property real temp: -1              // deg C
    property real diskAvail: 0          // bytes
    property real diskSize: 0
    readonly property real diskUsed: diskSize - diskAvail

    function gib(b) { return b / 1073741824; }

    Process {
        id: stats
        command: ["sh", "-c",
            "head -1 /proc/stat;" +
            "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo;" +
            "for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name)\" = coretemp ] && echo temp $(cat $h/temp1_input); done;" +
            "df -B1 --output=avail,size / | tail -1 | sed 's/^/disk /'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let memAvail = 0;
                for (const line of text.trim().split("\n")) {
                    const f = line.trim().split(/\s+/);
                    if (f[0] === "cpu") {
                        const v = f.slice(1).map(Number);
                        const idle = v[3] + (v[4] || 0);
                        const total = v.reduce((a, b) => a + b, 0);
                        const busy = total - idle;
                        if (menu.lastCpu && total > menu.lastCpu[1])
                            menu.cpu = 100 * (busy - menu.lastCpu[0]) / (total - menu.lastCpu[1]);
                        menu.lastCpu = [busy, total];
                    } else if (f[0] === "MemTotal:") {
                        menu.memTotal = Number(f[1]) * 1024;
                    } else if (f[0] === "MemAvailable:") {
                        memAvail = Number(f[1]) * 1024;
                    } else if (f[0] === "temp") {
                        menu.temp = Number(f[1]) / 1000;
                    } else if (f[0] === "disk") {
                        menu.diskAvail = Number(f[1]);
                        menu.diskSize = Number(f[2]);
                    }
                }
                menu.memUsed = menu.memTotal - memAvail;
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: stats.running = true
    }
    // second sample shortly after opening so CPU % shows up fast
    Timer {
        interval: 300
        running: true
        onTriggered: stats.running = true
    }

    // ---- section box ----
    component Section: Rectangle {
        property int cell: 0
        property int cols: 2
        property int rows: 1
        property string label: ""
        property string value: ""
        property string sub: ""
        property real pct: -1               // >= 0: dot bar instead of the value
        x: menu.cellX(cell)
        y: menu.cellY(cell)
        width: menu.spanW(cols)
        height: menu.spanH(rows)
        color: Theme.panel

        StyledText {
            x: 10; y: 8
            text: parent.label
            color: Theme.dim
            font.pixelSize: 11
            font.letterSpacing: 1.5
        }
        DotBar {
            x: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 11
            visible: parent.pct >= 0
            pct: parent.pct
        }
        StyledText {
            x: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            visible: parent.pct < 0
            text: parent.value
            font.pixelSize: 22
            font.weight: Font.Bold
        }
        StyledText {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 9
            text: parent.sub
            color: Theme.dim
            font.pixelSize: 11
        }
    }

    // ---- battery (cells 0-7) ----
    Section {
        id: batBox
        cell: 0; cols: 4; rows: 2
        label: "BATTERY"

        StyledText {
            anchors.right: parent.right
            anchors.rightMargin: 10
            y: 8
            color: Theme.dim
            font.pixelSize: 11
            text: (Battery.charging ? "charging" : Battery.plugged ? "plugged" : "discharging")
                + (Battery.timeLeft !== "" ? " · " + Battery.timeLeft + (Battery.charging ? " to full" : " left") : "")
        }

        StyledText {
            x: 10; y: 24
            text: Battery.pct + "%"
            color: Battery.color
            font.pixelSize: 30
            font.weight: Font.Bold
        }

        // 4 x 25 dots, 1 dot = 1 %. Empties right -> left, each column top -> bottom.
        Grid {
            id: dots
            readonly property int dot: 9
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            rows: 4
            columns: 25
            flow: Grid.TopToBottom
            spacing: 2
            Repeater {
                model: 100
                Rectangle {
                    required property int index
                    readonly property int c: Math.floor(index / 4)
                    readonly property int r: index % 4
                    readonly property bool empty: (24 - c) * 4 + r < 100 - Battery.pct
                    width: dots.dot
                    height: dots.dot
                    color: empty ? Theme.dim : Theme.fg
                    opacity: empty ? 0.3 : 1
                }
            }
        }
    }

    // ---- cpu (8-9), temp (10-11), ram (12-13), disk (14-15) ----
    Section {
        cell: 8
        label: "CPU"
        pct: Math.max(0, menu.cpu)
    }
    Section {
        cell: 10
        label: "TEMP"
        value: menu.temp < 0 ? "--" : Math.round(menu.temp) + "°C"
    }
    Section {
        cell: 12
        label: "RAM"
        pct: menu.memTotal ? 100 * menu.memUsed / menu.memTotal : 0
        sub: menu.memTotal ? menu.gib(menu.memUsed).toFixed(1) + "/" + Math.round(menu.gib(menu.memTotal)) + "G" : ""
    }
    Section {
        cell: 14
        label: "STORAGE"
        pct: menu.diskSize ? 100 * menu.diskUsed / menu.diskSize : 0
        sub: menu.diskSize ? Math.round(menu.gib(menu.diskUsed)) + "/" + Math.round(menu.gib(menu.diskSize)) + "G" : ""
    }
}
