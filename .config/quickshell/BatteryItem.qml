import QtQuick

BarItem {
    id: bat
    property bool blink: false
    // critical (on battery, <=10%) blinks red; full (plugged, >=90%) blinks lime
    readonly property bool alert: Battery.critical || Battery.full
    readonly property bool flash: alert && blink

    visible: Battery.available
    text: Battery.label
    textColor: flash ? (Battery.full ? Theme.bg : Theme.fg) : Battery.color
    keepColorOnHover: flash
    color: flash ? (Battery.full ? Theme.lime : Theme.red) : hovered ? Theme.fg : "transparent"
    tooltip: Battery.timeLeft

    Timer {
        running: bat.alert
        repeat: true
        interval: 500
        onTriggered: bat.blink = !bat.blink
        onRunningChanged: if (!running) bat.blink = false
    }
}
