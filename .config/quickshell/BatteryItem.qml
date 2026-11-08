import QtQuick
import Quickshell.Services.UPower

BarItem {
    id: bat
    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round(dev.percentage * 100)
    readonly property bool charging: dev.state === UPowerDeviceState.Charging
    readonly property bool plugged: !UPower.onBattery
    readonly property bool critical: !plugged && pct <= 10
    readonly property bool low: !plugged && pct <= 20
    property bool blink: false

    function fmtTime(secs) {
        if (!secs || secs <= 0) return "";
        const h = Math.floor(secs / 3600), m = Math.floor((secs % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "min";
    }

    visible: dev.ready && dev.isLaptopBattery
    text: (charging || plugged ? Theme.g(0xf0084)
         : critical ? Theme.g(0xf0083)
         : Theme.g([0xf12a1, 0xf12a2, 0xf12a3][Math.min(2, Math.floor(pct / 33.34))])) + " " + pct + "%"
    textColor: charging || plugged ? Theme.cyan : (critical && blink) ? Theme.fg : low ? Theme.red : Theme.fg
    color: critical && blink ? Theme.red : hovered ? Theme.fg : "transparent"
    tooltip: charging ? fmtTime(dev.timeToFull) : fmtTime(dev.timeToEmpty)

    Timer {
        running: bat.critical
        repeat: true
        interval: 500
        onTriggered: bat.blink = !bat.blink
        onRunningChanged: if (!running) bat.blink = false
    }
}
