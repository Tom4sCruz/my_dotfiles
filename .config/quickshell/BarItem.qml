import QtQuick
import Quickshell

// One module on the right side of the bar (text + hover style + mouse actions).
Rectangle {
    id: item
    property alias text: label.text
    property color textColor: Theme.fg
    property bool keepColorOnHover: false
    property string tooltip: ""
    property bool popupOpen: false
    readonly property bool hovered: hover.hovered
    signal clicked()
    signal rightClicked()
    signal scrolled(int direction)   // +1 up, -1 down

    implicitWidth: label.implicitWidth + 20
    implicitHeight: Theme.barHeight
    color: hovered || popupOpen ? Theme.fg : "transparent"

    StyledText {
        id: label
        anchors.centerIn: parent
        color: (item.hovered || item.popupOpen) && !item.keepColorOnHover ? Theme.bg : item.textColor
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => mouse.button === Qt.RightButton ? item.rightClicked() : item.clicked()
        onWheel: wheel => item.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
    }

    Tooltip {
        target: item
        text: item.tooltip
        show: item.hovered && !item.popupOpen
    }
}
