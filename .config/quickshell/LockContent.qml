import QtQuick
import QtQuick.Layouts
import Quickshell

// Everything drawn on a locked screen. `lock` is Lock.qml (shared state).
Rectangle {
    id: root
    required property var lock
    color: "black"

    SystemClock { id: clock; precision: SystemClock.Minutes }

    // real password lives here, never shown
    TextInput {
        id: input
        visible: false
        focus: true
        echoMode: TextInput.Password
        readOnly: root.lock.status === "auth"
        onTextChanged: {
            if (text !== root.lock.password) root.lock.password = text;
            if (text !== "" && root.lock.status === "failed") root.lock.status = "";
        }
        Keys.onReturnPressed: root.lock.submit()
        Keys.onEnterPressed: root.lock.submit()
        Keys.onEscapePressed: root.lock.password = ""
    }
    Connections {
        target: root.lock
        function onPasswordChanged() {
            if (input.text !== root.lock.password) input.text = root.lock.password;
            root.syncGlyphs();
        }
        function onStatusChanged() { if (root.lock.status === "failed") shake.restart(); }
    }

    ListModel { id: glyphs }
    function syncGlyphs() {
        const n = lock.password.length;
        while (glyphs.count < n) glyphs.append({});
        while (glyphs.count > n) glyphs.remove(glyphs.count - 1);
    }

    ColumnLayout {
        id: block
        x: root.width * 0.1
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 150
            font.weight: Font.Bold
        }
        Text {
            text: Qt.formatDateTime(clock.date, "dddd, dd MMMM")
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 28
            font.weight: Font.DemiBold
            Layout.leftMargin: 8
            Layout.topMargin: -10
        }

        // terminal-style prompt
        Item {
            id: prompt
            Layout.topMargin: 48
            Layout.leftMargin: 8
            implicitWidth: line.width
            implicitHeight: promptRow.height + 8 + line.height

            Row {
                id: promptRow
                spacing: 12

                Text {
                    text: "$"
                    color: Theme.accent
                    font.family: Theme.font
                    font.pixelSize: 26
                    font.weight: Font.Bold
                }
                Row {
                    spacing: 2
                    Repeater {
                        model: glyphs
                        MatrixGlyph {}
                    }
                    Text {
                        id: cursor
                        text: "█"
                        color: Theme.accent
                        font.family: Theme.font
                        font.pixelSize: 26
                        visible: root.lock.status !== "auth"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0; duration: 1; }
                            PauseAnimation { duration: 530 }
                            NumberAnimation { to: 1; duration: 1; }
                            PauseAnimation { duration: 530 }
                        }
                    }
                }
            }

            Rectangle {
                id: line
                y: promptRow.height + 8
                width: 380
                height: 1
                color: root.lock.status === "failed" ? Theme.red
                     : root.lock.password !== "" ? Theme.accent : Theme.dim
            }

            SequentialAnimation {
                id: shake
                NumberAnimation { target: prompt; property: "Layout.leftMargin"; to: 22; duration: 50 }
                NumberAnimation { target: prompt; property: "Layout.leftMargin"; to: -6; duration: 50 }
                NumberAnimation { target: prompt; property: "Layout.leftMargin"; to: 18; duration: 50 }
                NumberAnimation { target: prompt; property: "Layout.leftMargin"; to: 8; duration: 50 }
            }
        }

        Text {
            Layout.topMargin: 10
            Layout.leftMargin: 8
            text: root.lock.status === "failed" ? "authentication failed"
                : root.lock.status === "auth" ? "authenticating…" : " "
            color: root.lock.status === "failed" ? Theme.red : Theme.dim
            font.family: Theme.font
            font.pixelSize: 14
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        visible: Battery.available
        text: Battery.label
        color: Battery.color
        font.family: Theme.font
        font.pixelSize: 18
        font.weight: Font.DemiBold
    }

    Component.onCompleted: { syncGlyphs(); input.forceActiveFocus(); }
}
