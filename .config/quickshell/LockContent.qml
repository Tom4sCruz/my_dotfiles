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
        readOnly: root.lock.status !== ""
        onTextChanged: if (text !== root.lock.password) root.lock.password = text
        Keys.onReturnPressed: root.lock.submit()
        Keys.onEnterPressed: root.lock.submit()
        Keys.onEscapePressed: if (root.lock.status === "") root.lock.password = ""
    }
    Connections {
        target: root.lock
        function onPasswordChanged() {
            if (input.text !== root.lock.password) input.text = root.lock.password;
            root.syncGlyphs();
        }
        function onStatusChanged() {
            if (root.lock.status === "failed") {
                failBlink.restart();
            } else {
                failBlink.stop();
                field.inverted = false;
            }
        }
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
            text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 28
            font.weight: Font.DemiBold
            Layout.leftMargin: 8
            Layout.topMargin: -10
        }
    }

    // password field: vertical bar on the right, glyphs stack top -> bottom
    //   white = typing/idle, amber = authenticating, lime = ok, red = wrong
    Rectangle {
        id: field
        anchors.right: parent.right
        anchors.rightMargin: root.width * 0.1
        anchors.verticalCenter: parent.verticalCenter
        width: 56
        height: root.height * 0.6
        clip: true
        property bool inverted: false      // wrong-password blink: black bar, red outline + glyphs
        border.width: inverted ? 2 : 0
        border.color: Theme.red
        color: root.lock.status === "auth" ? Theme.amber
             : root.lock.status === "failed" ? (inverted ? "black" : Theme.red)
             : root.lock.status === "success" ? Theme.lime
             : Theme.fg
        Behavior on color { enabled: root.lock.status !== "failed"; ColorAnimation { duration: 120 } }

        Column {
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2
            Repeater {
                model: glyphs
                MatrixGlyph {
                    color: field.inverted ? Theme.red : "black"
                    width: field.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // red -> 2 blinks -> red; total = failReset in Lock.qml (1350 ms)
        SequentialAnimation {
            id: failBlink
            PauseAnimation { duration: 300 }
            PropertyAction { target: field; property: "inverted"; value: true }
            PauseAnimation { duration: 250 }
            PropertyAction { target: field; property: "inverted"; value: false }
            PauseAnimation { duration: 250 }
            PropertyAction { target: field; property: "inverted"; value: true }
            PauseAnimation { duration: 250 }
            PropertyAction { target: field; property: "inverted"; value: false }
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
