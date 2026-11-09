import QtQuick

// Square, flat button holding a Nerd Font glyph.
//   normal: transparent, grey on hover
//   filled: light background, inverts on hover (white square, dark icon) - play/pause
Rectangle {
    id: button
    property alias text: label.text
    property alias glyphSize: label.font.pixelSize
    property int size: 28
    property bool filled: false
    readonly property bool hot: mouse.containsMouse && enabled
    signal clicked()

    implicitWidth: size
    implicitHeight: size
    color: hot ? (filled ? Theme.fg : Theme.hover) : (filled ? Theme.buttonBg : "transparent")
    opacity: enabled ? 1 : 0.35

    StyledText {
        id: label
        anchors.centerIn: parent
        color: button.filled && button.hot ? Theme.bg : Theme.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
