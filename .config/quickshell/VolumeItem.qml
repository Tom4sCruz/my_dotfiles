import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarItem {
    id: vol
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool bt: sink !== null && (sink.name || "").startsWith("bluez")
    readonly property bool muted: sink !== null && sink.audio !== null && sink.audio.muted
    readonly property int pct: sink !== null && sink.audio !== null ? Math.round(sink.audio.volume * 100) : 0

    PwObjectTracker { objects: vol.sink ? [vol.sink] : [] }

    text: muted ? Theme.g(0xf075f) + " 0%"
        : (bt ? "" : Theme.g(pct < 50 ? 0xf0580 : 0xf057e)) + " " + pct + "%"
    textColor: muted ? Theme.orange : bt ? Theme.blue : Theme.fg
    tooltip: Theme.sinkName(sink)
    popupOpen: popup.open

    // if the other overlay is open, hovering this item hands over to ours
    property var peers: []
    function closePopup() { popup.open = false; }
    onHoveredChanged: {
        const open = peers.filter(p => p && p.popupOpen);
        if (hovered && open.length) { open.forEach(p => p.closePopup()); popup.open = true; }
    }

    onClicked: popup.open = !popup.open
    onRightClicked: { popup.open = false; Quickshell.execDetached(["pavucontrol"]); }
    onScrolled: dir => Quickshell.execDetached(["wpctl", "set-volume", "-l", "1",
        "@DEFAULT_AUDIO_SINK@", dir > 0 ? "5%+" : "5%-"])

    Connections {
        target: PopupState
        function onToggleRequested(name, monitor) {
            if (name === "audio" && monitor === vol.QsWindow.window.screen.name) popup.open = !popup.open;
        }
        function onCloseAll() { popup.open = false; }
    }

    DockedPopup {
        side: "right"
        id: popup
        target: vol
        targetHovered: vol.hovered
        content: Component { AudioMenu {} }
    }
}
