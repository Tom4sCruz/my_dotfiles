import QtQuick

BarItem {
    id: bat
    property bool blink: false

    visible: Battery.available
    text: Battery.label
    textColor: Battery.critical && blink ? Theme.fg : Battery.color
    color: Battery.critical && blink ? Theme.red : hovered ? Theme.fg : "transparent"
    tooltip: Battery.timeLeft

    Timer {
        running: Battery.critical
        repeat: true
        interval: 500
        onTriggered: bat.blink = !bat.blink
        onRunningChanged: if (!running) bat.blink = false
    }
}
