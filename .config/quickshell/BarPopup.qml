import QtQuick
import Quickshell

// Overlay card under a bar item. Content is (re)created each time it opens.
// Closes ~300 ms after the cursor is neither on the item nor on the card.
PopupWindow {
    id: pop
    required property Item target
    property bool targetHovered: false
    property bool open: false
    property Component content
    readonly property bool hovered: cardHover.hovered

    anchor.item: target
    anchor.rect: Qt.rect(target.width / 2, target.height + Theme.gap, 1, 1)
    anchor.gravity: Edges.Bottom
    color: "transparent"
    implicitWidth: frame.width
    implicitHeight: frame.height
    visible: open

    // only start the leave-timer once the cursor has been on the item/card
    // (a popup opened from a keybind/IPC shouldn't vanish instantly)
    property bool armed: false
    onOpenChanged: armed = open && (targetHovered || hovered)
    onTargetHoveredChanged: if (open && targetHovered) armed = true
    onHoveredChanged: if (open && hovered) armed = true
    readonly property bool cursorAway: open && armed && !targetHovered && !hovered
    onCursorAwayChanged: cursorAway ? leaveTimer.restart() : leaveTimer.stop()

    Timer {
        id: leaveTimer
        interval: 300
        onTriggered: if (pop.cursorAway) pop.open = false
    }

    Rectangle {
        id: frame
        width: loader.width + 2 * Theme.padding
        height: loader.height + 2 * Theme.padding
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.border
        border.width: 1

        HoverHandler { id: cardHover }

        Loader {
            id: loader
            x: Theme.padding
            y: Theme.padding
            active: pop.open
            sourceComponent: pop.content
        }
    }
}
