import QtQuick
import Quickshell

BarItem {
    id: bat
    property bool blink: false
    // critical (on battery, <=10%) blinks red; full (plugged, >=90%) is steady green
    readonly property bool flash: Battery.critical && blink
    readonly property bool solid: flash || Battery.full

    visible: Battery.available
    text: Battery.label
    textColor: solid ? (Battery.full ? Theme.bg : Theme.fg) : Battery.color
    keepColorOnHover: solid
    color: Battery.full ? Theme.green : flash ? Theme.red : hovered || popupOpen ? Theme.fg : "transparent"
    popupOpen: popup.open
    tooltip: Battery.timeLeft

    Timer {
        running: Battery.critical
        repeat: true
        interval: 500
        onTriggered: bat.blink = !bat.blink
        onRunningChanged: if (!running) bat.blink = false
    }

    // click -> system overlay (battery / cpu / temp / ram / disk)
    // if the audio / wifi overlay is open, hovering this item hands over to ours
    property var peers: []
    function closePopup() { popup.open = false; }
    onHoveredChanged: {
        const open = peers.filter(p => p && p.popupOpen);
        if (hovered && open.length) { open.forEach(p => p.closePopup()); popup.open = true; }
    }
    onClicked: popup.open = !popup.open

    Connections {
        target: PopupState
        function onToggleRequested(name, monitor) {
            if (name === "system" && monitor === bat.QsWindow.window.screen.name) popup.open = !popup.open;
        }
        function onCloseAll() { popup.open = false; }
    }

    DockedPopup {
        id: popup
        side: "right"
        target: bat
        targetHovered: bat.hovered
        content: Component { SystemMenu {} }
    }
}
