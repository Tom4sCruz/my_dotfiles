import QtQuick

// 2 x 10 dots, 1 dot = 5 %. Fills left -> right, each column bottom -> top
// (the mirror of the battery grid emptying right -> left, top -> bottom).
Grid {
    id: bar
    property real pct: 0
    readonly property int lit: Math.round(Math.max(0, Math.min(100, pct)) / 5)
    rows: 2
    columns: 10
    flow: Grid.TopToBottom
    spacing: 2
    Repeater {
        model: 20
        Rectangle {
            required property int index
            readonly property bool on: Math.floor(index / 2) * 2 + (1 - index % 2) < bar.lit
            width: 7
            height: 7
            color: on ? Theme.fg : Theme.dim
            opacity: on ? 1 : 0.3
        }
    }
}
