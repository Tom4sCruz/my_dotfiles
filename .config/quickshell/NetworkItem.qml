import QtQuick
import Quickshell
import Quickshell.Networking

BarItem {
    id: net
    readonly property var devices: Networking.devices.values
    readonly property var wifiDev: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wifi: wifiDev ? (wifiDev.networks.values.find(n => n.connected) ?? null) : null
    readonly property bool wired: devices.some(d => d.type === DeviceType.Wired && d.connected)
    readonly property int signal: wifi ? Math.round(wifi.signalStrength * 100) : 0

    text: wifi ? Theme.g(0xf05a9) + " " + signal + "%"
        : wired ? ""
        : " 0%"
    textColor: wifi || wired ? Theme.fg : Theme.orange
    tooltip: wifi ? wifi.name + " (" + signal + "%)" : wired ? "Ethernet" : "Disconnected"
    popupOpen: popup.open

    // if the other overlay is open, hovering this item hands over to ours
    property Item peer: null
    function closePopup() { popup.open = false; }
    onHoveredChanged: if (hovered && peer && peer.popupOpen) { peer.closePopup(); popup.open = true; }

    onClicked: popup.open = !popup.open
    onRightClicked: { popup.open = false; Quickshell.execDetached(["nm-connection-editor"]); }

    Connections {
        target: PopupState
        function onToggleRequested(name, monitor) {
            if (name === "wifi" && monitor === net.QsWindow.window.screen.name) popup.open = !popup.open;
        }
        function onCloseAll() { popup.open = false; }
    }

    DockedPopup {
        side: "right"
        id: popup
        target: net
        targetHovered: net.hovered
        content: Component { WifiMenu {} }
    }
}
