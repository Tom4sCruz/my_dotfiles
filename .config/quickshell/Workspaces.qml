import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: ws
    required property var screen
    readonly property var monitor: Hyprland.monitorFor(screen)

    function go(target) { Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })"); }

    Repeater {
        model: Hyprland.workspaces.values
            .filter(w => w.id > 0 && w.monitor && ws.monitor && w.monitor.name === ws.monitor.name)
            .sort((a, b) => a.id - b.id)

        Rectangle {
            id: button
            required property var modelData
            readonly property bool isActive: modelData.focused              // waybar "active"
            readonly property bool isVisible: modelData.active && !isActive // shown on its monitor
            implicitWidth: Math.max(label.implicitWidth + 8, 16)
            implicitHeight: Theme.barHeight
            color: isActive ? Theme.fg : hover.hovered ? Theme.barHover : "transparent"
            border.width: isVisible ? 1 : 0
            border.color: Theme.fg

            StyledText {
                id: label
                anchors.centerIn: parent
                text: button.modelData.name
                color: button.isActive ? Theme.bg : Theme.fg
            }
            HoverHandler { id: hover }
            MouseArea {
                anchors.fill: parent
                onClicked: ws.go(button.modelData.id)
            }
        }
    }

    // scroll over the workspaces -> previous / next one on this monitor
    WheelHandler {
        onWheel: event => ws.go(event.angleDelta.y > 0 ? '"m-1"' : '"m+1"')
    }
}
