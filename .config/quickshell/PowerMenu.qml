import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Power menu (replaces wlogout). Open with:  qs ipc call power toggle
// Square tiles on the left: light options (sleep, lock), a gap, then the
// crucial ones (reboot, power off).
//   keys: S sleep · L lock · R reboot · P power off · arrows/j/k + Enter · Esc
Scope {
    id: power
    required property var lock         // Lock.qml
    property bool open: false
    property int selected: -1

    readonly property var entries: [
        { key: "S", label: "SLEEP",     hover: Theme.fg,    text: Theme.bg, run: () => Quickshell.execDetached(["sh", "-c", "loginctl lock-session && systemctl suspend"]) },
        { key: "L", label: "LOCK",      hover: Theme.fg,    text: Theme.bg, run: () => power.lock.activate() },
        { key: "R", label: "REBOOT",    hover: Theme.green, text: Theme.bg, run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { key: "P", label: "POWER OFF", hover: Theme.red,   text: Theme.fg, run: () => Quickshell.execDetached(["systemctl", "poweroff"]) },
    ]

    function toggle() { selected = -1; open = !open; }
    function trigger(i) { open = false; entries[i].run(); }
    function step(d) {
        const n = entries.length;
        selected = selected < 0 ? (d > 0 ? 0 : n - 1) : (selected + d + n) % n;
    }

    PanelWindow {
        visible: power.open
        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name)
            ?? Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-power"
        color: Qt.rgba(16 / 255, 16 / 255, 16 / 255, 0.75)

        // click outside the tiles closes
        MouseArea {
            anchors.fill: parent
            onClicked: power.open = false
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                const k = event.key;
                const idx = power.entries.findIndex(e => Qt["Key_" + e.key] === k);
                if (idx >= 0) power.trigger(idx);
                else if (k === Qt.Key_Escape) power.open = false;
                else if (k === Qt.Key_Down || k === Qt.Key_J || k === Qt.Key_Tab) power.step(1);
                else if (k === Qt.Key_Up || k === Qt.Key_K || k === Qt.Key_Backtab) power.step(-1);
                else if ((k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) && power.selected >= 0)
                    power.trigger(power.selected);
                else return;
                event.accepted = true;
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Repeater {
                model: power.entries
                Rectangle {
                    id: tile
                    required property var modelData
                    required property int index
                    readonly property bool active: power.selected === index
                    width: 160
                    height: 160 + (index === 1 ? 30 : 0)   // 10 + 30 = 40 px gap between the groups
                    color: "transparent"

                    Rectangle {
                        width: 160
                        height: 160
                        color: tile.active ? tile.modelData.hover : "#101010"

                        StyledText {
                            anchors.centerIn: parent
                            text: tile.modelData.label
                            color: tile.active ? tile.modelData.text : Theme.fg
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: power.selected = tile.index
                            onExited: if (power.selected === tile.index) power.selected = -1
                            onClicked: power.trigger(tile.index)
                        }
                    }
                }
            }
        }
    }
}
