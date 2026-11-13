import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Notification daemon (replaces dunst). Cards stack just above the OSD slot,
// newest at the bottom, sliding in from below. Click to dismiss.
//   border: low = green (important), normal = white, critical = red (urgent)
Scope {
    id: root
    readonly property int maxShown: 5
    readonly property int cardWidth: 360

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: false
        persistenceSupported: true
        onNotification: n => {
            n.tracked = true;
            const shown = server.trackedNotifications.values;
            if (shown.length > root.maxShown) shown[0].expire();
        }
    }

    function accent(n) {
        return n.urgency === NotificationUrgency.Critical ? Theme.red
             : n.urgency === NotificationUrgency.Low ? Theme.green
             : Theme.fg;
    }

    function iconFor(n) {
        if (n.image) return n.image;
        const icon = n.appIcon || n.desktopEntry || "";
        if (icon === "") return "";
        if (icon.startsWith("/")) return "file://" + icon;
        if (icon.startsWith("file://") || icon.startsWith("image://")) return icon;
        return Quickshell.iconPath(icon, true);
    }

    PanelWindow {
        id: win
        visible: server.trackedNotifications.values.length > 0
        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name)
            ?? Quickshell.screens[0]
        anchors.bottom: true
        margins.bottom: 80 + 66 + 10            // just above the OSD (Osd.qml)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        color: "transparent"
        implicitWidth: root.cardWidth
        implicitHeight: 720
        mask: Region { item: stack }

        Column {
            id: stack
            anchors.bottom: parent.bottom
            width: parent.width
            spacing: 0

            Repeater {
                model: server.trackedNotifications

                // slot: height animates so older cards slide up smoothly
                Item {
                    id: slot
                    required property var modelData
                    readonly property var n: modelData
                    readonly property color accent: root.accent(n)
                    property bool leaving: false
                    property real shown: 0           // 0 -> 1 on enter, 1 -> 0 on leave
                    width: stack.width
                    height: (card.height + 8) * shown
                    clip: false

                    function close(expired) {
                        if (leaving) return;
                        leaving = true;
                        exitAnim.expired = expired;
                        exitAnim.start();
                    }

                    NumberAnimation on shown {
                        id: enterAnim
                        from: 0; to: 1
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        id: exitAnim
                        property bool expired: false
                        NumberAnimation { target: slot; property: "shown"; to: 0; duration: 180; easing.type: Easing.InCubic }
                        ScriptAction { script: exitAnim.expired ? slot.n.expire() : slot.n.dismiss() }
                    }

                    Timer {
                        interval: slot.n.expireTimeout > 0 ? slot.n.expireTimeout * 1000
                            : slot.n.urgency === NotificationUrgency.Critical ? 50000 : 10000
                        running: !hover.hovered && !slot.leaving
                        onTriggered: slot.close(true)
                    }

                    Rectangle {
                        id: card
                        width: parent.width
                        height: row.implicitHeight + 24
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        // slide in from below + fade
                        transform: Translate { y: (1 - slot.shown) * 40 }
                        opacity: slot.shown
                        color: "black"
                        border.color: slot.accent
                        border.width: hover.hovered ? 3 : 1
                        Behavior on border.width { NumberAnimation { duration: 80 } }

                        HoverHandler { id: hover }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.AllButtons
                            cursorShape: Qt.PointingHandCursor
                            onClicked: slot.close(false)
                        }

                        RowLayout {
                            id: row
                            x: 12; y: 12
                            width: parent.width - 24
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignTop
                                Image {
                                    id: icon
                                    anchors.fill: parent
                                    source: root.iconFor(slot.n)
                                    sourceSize: Qt.size(64, 64)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: status === Image.Ready
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    visible: icon.status !== Image.Ready
                                    color: Theme.bgAlt
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: (slot.n.appName || "?").charAt(0).toUpperCase()
                                        color: Theme.dim
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                StyledText {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: (slot.n.summary || slot.n.appName || "").toUpperCase()
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1.5
                                    elide: Text.ElideRight
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: slot.n.body
                                    textFormat: Text.StyledText
                                    font.pixelSize: 13
                                    font.weight: Font.Normal
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
