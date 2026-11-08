import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

// Session lock. Lock with:  qs ipc call lock lock
// Preview (normal window, no real lock, Esc closes):  qs ipc call lock preview
Scope {
    id: lockRoot
    property string password: ""
    property string status: ""     // "" | "auth" | "failed"
    property bool previewing: false

    function activate() {
        password = "";
        status = "";
        sessionLock.locked = true;
    }

    function submit() {
        if (password === "" || status === "auth") return;
        if (previewing && !sessionLock.locked) {     // preview: never authenticates
            status = "failed";
            password = "";
            return;
        }
        status = "auth";
        pam.start();
    }

    PamContext {
        id: pam
        config: "hyprlock"                 // /etc/pam.d/hyprlock -> include login
        onResponseRequiredChanged: if (responseRequired) respond(lockRoot.password)
        onCompleted: result => {
            if (result === PamResult.Success) {
                sessionLock.locked = false;
                lockRoot.status = "";
            } else {
                lockRoot.status = "failed";
            }
            lockRoot.password = "";
        }
        onError: {
            lockRoot.status = "failed";
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
