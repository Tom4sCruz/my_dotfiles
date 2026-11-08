import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

ColumnLayout {
    id: menu
    spacing: 2

    // sink names whose active port is unplugged (e.g. HDMI with no display)
    property var unavailable: []

    readonly property var sinks: Pipewire.nodes.values.filter(n =>
        n.isSink && !n.isStream && n.audio && !unavailable.includes(n.name))

    PwObjectTracker { objects: menu.sinks }

    Process {
        running: true
        command: ["pactl", "-f", "json", "list", "sinks"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    menu.unavailable = JSON.parse(text)
                        .filter(s => (s.ports || []).some(p =>
                            p.name === s.active_port && p.availability === "not available"))
                        .map(s => s.name);
                } catch (e) {}
            }
        }
    }

    StyledText {
        text: "Sound Output"
        font.weight: Font.Bold
        Layout.leftMargin: 6
        Layout.bottomMargin: 6
    }

    Repeater {
        model: menu.sinks
        ListRow {
            required property var modelData
            Layout.fillWidth: true
            icon: modelData.name.startsWith("bluez") ? "" : "" // headphones / speaker
            label: Theme.sinkName(modelData)
            active: Pipewire.defaultAudioSink !== null && Pipewire.defaultAudioSink.id === modelData.id
            onClicked: Pipewire.preferredDefaultAudioSink = modelData
        }
    }

    StyledText {
        visible: menu.sinks.length === 0
        text: "No output devices"
        color: Theme.dim
        Layout.leftMargin: 6
    }
}
