pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery state + icon, shared by the bar and the lock screen.
Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool available: dev.ready && dev.isLaptopBattery
    readonly property int pct: Math.round(dev.percentage * 100)
    readonly property bool charging: dev.state === UPowerDeviceState.Charging
    readonly property bool plugged: !UPower.onBattery
    readonly property bool critical: !plugged && pct <= 10
    readonly property bool low: !plugged && pct <= 20
    readonly property bool full: plugged && pct >= 90     // time to unplug

    readonly property string icon: charging || plugged ? Theme.g(0xf0084)
        : critical ? Theme.g(0xf0083)
        : Theme.g([0xf12a1, 0xf12a2, 0xf12a3][Math.min(2, Math.floor(pct / 33.34))])
    readonly property string label: icon + " " + pct + "%"
    readonly property color color: charging || plugged ? Theme.cyan : low ? Theme.red : Theme.fg

    function fmtTime(secs) {
        if (!secs || secs <= 0) return "";
        const h = Math.floor(secs / 3600), m = Math.floor((secs % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "min";
    }
    readonly property string timeLeft: charging ? fmtTime(dev.timeToFull) : fmtTime(dev.timeToEmpty)
}
