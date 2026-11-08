import QtQuick
import QtQuick.Layouts

// One selectable row in the audio / wifi lists.
Rectangle {
    id: row
    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property bool active: false
    signal clicked()

    implicitWidth: 320
    implicitHeight: 36
    radius: 6
    color: active ? Theme.accentSoft : mouse.containsMouse ? Theme.hover : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        StyledText {
            text: row.icon
            color: row.active ? Theme.accent : Theme.fg
            Layout.preferredWidth: 18
            horizontalAlignment: Text.AlignHCenter
        }
        StyledText {
            text: row.label
            color: row.active ? Theme.accent : Theme.fg
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        StyledText {
            text: row.sublabel
            visible: text !== ""
            color: Theme.dim
            font.pixelSize: 12
        }
        StyledText {
            text: "" // check
            visible: row.active
            color: Theme.accent
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.clicked()
    }
}
