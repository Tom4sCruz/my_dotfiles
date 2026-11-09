import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

// Overlay that looks like an extension of the bar: flush under it, square,
// with an outward cut corner where it meets the bar.
//   side: "right"  -> touches the right screen edge, cut on the top-left
//   side: "center" -> centered under the bar, cut on both top corners
// Content is (re)created each time it opens. Closes ~300 ms after the cursor
// is neither on the bar item nor on the overlay.
PanelWindow {
    id: pop
    required property Item target
    property bool targetHovered: false
    property bool open: false
    property Component content
    property string side: "right"
    readonly property bool hovered: hover.hovered

    readonly property int cutL: Theme.cut
    readonly property int cutR: side === "center" ? Theme.cut : 0
    readonly property int bodyW: loader.width + 2 * Theme.padding
    readonly property int bodyH: loader.height + 2 * Theme.padding

    screen: target.QsWindow.window ? target.QsWindow.window.screen : null
    anchors { top: true; right: side === "right" }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell-overlay"
    color: "transparent"
    implicitWidth: cutL + bodyW + cutR
    implicitHeight: Math.max(bodyH, Theme.cut + 1)
    visible: open

    // only start the leave-timer once the cursor has been on the item/overlay
    // (an overlay opened from a keybind/IPC shouldn't vanish instantly)
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

    Item {
        anchors.fill: parent
        HoverHandler { id: hover }

        Shape {
            id: shape
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real w: pop.implicitWidth
            readonly property real h: pop.implicitHeight
            readonly property real l: pop.cutL
            readonly property real r: w - pop.cutR

            // fill: body + cut triangle(s), same color as the bar
            ShapePath {
                strokeWidth: -1
                fillColor: Theme.bg
                startX: 0; startY: 0
                PathLine { x: shape.w; y: 0 }
                PathLine { x: shape.r; y: pop.cutR }
                PathLine { x: shape.r; y: shape.h }
                PathLine { x: shape.l; y: shape.h }
                PathLine { x: shape.l; y: pop.cutL }
                PathLine { x: 0; y: 0 }
            }

            // outline: diagonal(s), sides and bottom - no line along the bar
            // I DO NOT NEED THIS. 
            // This is merely a border that I want to look over.
            // See how it was done.

            ShapePath {
                strokeColor: Theme.bg
                strokeWidth: 1
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap
                joinStyle: ShapePath.MiterJoin
                startX: 0; startY: 0
                PathLine { x: shape.l + 0.5; y: pop.cutL }
                PathLine { x: shape.l + 0.5; y: shape.h - 0.5 }
                PathLine { x: pop.cutR > 0 ? shape.r - 0.5 : shape.w; y: shape.h - 0.5 }
                PathLine { x: shape.r - 0.5; y: pop.cutR > 0 ? pop.cutR : shape.h - 0.5 }
                PathLine { x: shape.w; y: 0 }
            }
        }

        Loader {
            id: loader
            x: pop.cutL + Theme.padding
            y: Theme.padding
            active: pop.open
            sourceComponent: pop.content
        }
    }
}
