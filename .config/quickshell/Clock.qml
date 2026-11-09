import QtQuick
import Quickshell

// Hover -> calendar + media overlay.
Item {
    id: clock
    implicitWidth: label.implicitWidth + 20
    implicitHeight: Theme.barHeight
    readonly property bool hovered: hover.hovered
    property alias popupOpen: popup.open

    SystemClock { id: sys; precision: SystemClock.Minutes }

    StyledText {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(sys.date, "MMM dd  HH:mm")
    }

    HoverHandler { id: hover }

    // small delay so just sweeping the cursor across the bar doesn't open it
    Timer {
        id: openDelay
        interval: 150
        onTriggered: if (clock.hovered) popup.open = true
    }
    onHoveredChanged: if (hovered) openDelay.restart()

    DockedPopup {
        side: "center"
        id: popup
        target: clock
        targetHovered: clock.hovered
        content: Component { CalendarMedia {} }
    }
}
