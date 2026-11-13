import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire

// Volume / brightness indicator near the bottom of the focused screen.
//   volume: reacts to the default sink's volume/mute changing
//   brightness: qs ipc call osd brightness   (called from the hyprland binds)
Scope {
    id: osd
    property string label: ""
    property int pct: 0
    property bool muted: false
    property bool shown: false

    function show(name, value, isMuted) {
        label = name;
        pct = Math.max(0, Math.min(100, value));
        muted = isMuted;
        shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osd.shown = false
    }

    // ---- volume ----
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: osd.sink ? [osd.sink] : [] }
    // a sink switch (or the tracker binding) shouldn't pop the OSD
    property bool sinkSettled: false
    onSinkChanged: { sinkSettled = false; settle.restart(); }
    Timer { id: settle; interval: 500; onTriggered: osd.sinkSettled = true }

    function showVolume() {
        if (!sinkSettled || !sink || !sink.audio) return;
        show("Volume", Math.round(sink.audio.volume * 100), sink.audio.muted);
    }
    Connections {
        target: osd.sink ? osd.sink.audio : null
        function onVolumeChanged() { osd.showVolume(); }
        function onMutedChanged() { osd.showVolume(); }
    }

    // ---- brightness ----
    Process {
        id: brightness
        command: ["brightnessctl", "-e4", "-m", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                if (f.length >= 4) osd.show("Brightness", parseInt(f[3]), false);
            }
        }
    }

    IpcHandler {
        target: "osd"
        function brightness(): void { brightness.running = true; }
        function volume(): void { osd.showVolume(); }
    }

    // ---- window ----
    PanelWindow {
        id: win
        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name)
            ?? Quickshell.screens[0]
        visible: osd.shown
        anchors.bottom: true
        margins.bottom: 80
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-osd"
        mask: Region {}
        color: "transparent"
        implicitWidth: box.width
        implicitHeight: box.height

        Rectangle {
            id: box
            readonly property int bars: 20
            readonly property int lit: osd.muted ? 0 : Math.round(osd.pct / 5)
            width: 360
            height: 66
            color: "black"

            StyledText {
                x: 12; y: 8
                text: osd.label.toUpperCase() + (osd.muted ? " · MUTED" : "")
                color: Theme.dim
                font.pixelSize: 11
                font.letterSpacing: 1.5
            }

            Row {
                x: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                spacing: 5
                Repeater {
                    model: box.bars
                    Rectangle {
                        required property int index
                        width: (box.width - 24 - (box.bars - 1) * 5) / box.bars
                        height: 26
                        color: Theme.fg
                        opacity: index < box.lit ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 90 } }
                    }
                }
            }
        }
    }
}
