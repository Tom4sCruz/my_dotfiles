import QtQuick
import Quickshell

// Small text bubble under a bar item, shown after a short hover.
PopupWindow {
    id: tip
    required property Item target
    property string text: ""
    property bool show: false

    anchor.item: target
    anchor.rect: Qt.rect(target.width / 2, target.height + Theme.gap, 1, 1)
    anchor.gravity: Edges.Bottom
    color: "transparent"
    implicitWidth: bubble.width
    implicitHeight: bubble.height
    visible: false

    onShowChanged: show ? delay.restart() : (delay.stop(), visible = false)

    Timer {
        id: delay
        interval: 400
        onTriggered: tip.visible = tip.show && tip.text !== ""
    }

    Rectangle {
        id: bubble
        width: label.implicitWidth + 16
        height: label.implicitHeight + 10
        color: Theme.bg
        radius: 6
        border.color: Theme.border
        border.width: 1

        StyledText {
            id: label
            anchors.centerIn: parent
            text: tip.text
            font.pixelSize: 13
        }
    }
}
