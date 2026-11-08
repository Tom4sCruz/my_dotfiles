import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 18

    Calendar {
        Layout.alignment: Qt.AlignTop
    }
    Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        color: Theme.border
    }
    MediaPlayer {
        Layout.alignment: Qt.AlignTop
    }
}
