import QtQuick
import Quickshell
import Quickshell.Bluetooth

BarItem {
    id: bt
    readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)
    readonly property var withBattery: connected.find(d => d.batteryAvailable) ?? null

    visible: connected.length > 0
    text: Theme.g(0xf00af) + (withBattery ? " " + Math.round(withBattery.battery * 100) + "%" : "")
    textColor: Theme.blue
    keepColorOnHover: true
    tooltip: connected.map(d => d.name + (d.batteryAvailable ? "  " + Math.round(d.battery * 100) + "%" : "")).join("\n")

    onClicked: Quickshell.execDetached(["blueman-manager"])
}
