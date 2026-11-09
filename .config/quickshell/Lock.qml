import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

// Session lock. Lock with:  qs ipc call lock lock
// Preview (normal window, no real lock, Esc closes):  qs ipc call lock preview
Scope {
    id: lockRoot
    property string password: ""
    property string status: ""     // "" | "auth" | "failed" | "success"
    property bool previewing: false

    function activate() {
        password = "";
        status = "";
        failReset.stop();
        sessionLock.locked = true;
    }

    function submit() {
        if (password === "" || status === "auth" || status === "success" || status === "failed") return;
        if (previewing && !sessionLock.locked) {     // preview: never authenticates
            fail();
            return;
        }
        status = "auth";
        pam.start();
    }

    // wrong password: keep the glyphs while the bar blinks red, then reset
    function fail() {
        status = "failed";
        failReset.restart();
    }

    Timer {
        id: failReset
        interval: 1350                     // matches failBlink in LockContent.qml
        onTriggered: {
            lockRoot.password = "";
            lockRoot.status = "";
        }
    }

    PamContext {
        id: pam
        config: "hyprlock"                 // /etc/pam.d/hyprlock -> include login
        onResponseRequiredChanged: if (responseRequired) respond(lockRoot.password)
        onCompleted: result => {
            if (result === PamResult.Success) {
                lockRoot.status = "success";     // show lime briefly, then unlock
                unlockDelay.restart();
            } else {
                lockRoot.fail();
            }
        }
        onError: lockRoot.fail()
    }

    Timer {
        id: unlockDelay
        interval: 400
        onTriggered: {
            sessionLock.locked = false;
            lockRoot.status = "";
            lockRoot.password = "";
        }
    }

    WlSessionLock {
        id: sessionLock
        WlSessionLockSurface {
            color: "black"
            LockContent {
                anchors.fill: parent
                lock: lockRoot
            }
        }
    }

    LazyLoader {
        active: lockRoot.previewing
        FloatingWindow {
            title: "lock preview"
            implicitWidth: 1280
            implicitHeight: 720
            color: "black"
            LockContent {
                anchors.fill: parent
                lock: lockRoot
                Keys.onEscapePressed: lockRoot.previewing = false
            }
            Shortcut { sequence: "Escape"; onActivated: lockRoot.previewing = false }
        }
    }
}
