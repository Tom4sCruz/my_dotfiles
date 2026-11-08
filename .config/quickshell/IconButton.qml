import QtQuick

// Round, flat button holding a Nerd Font glyph.
Rectangle {
    id: button
    property alias text: label.text
    property alias glyphSize: label.font.pixelSize
    property int size: 28
    property bool filled: false       // light circle with dark glyph (play button)
    signal clicked()

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: filled ? (mouse.containsMouse ? Theme.accent : Theme.fg)
                  : (mouse.containsMouse && enabled ? Theme.hover : "transparent")
    opacity: enabled ? 1 : 0.35

    StyledText {
        id: label
        anchors.centerIn: parent
        color: button.filled ? Theme.bg : Theme.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
