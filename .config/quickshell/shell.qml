import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    Bar {}
    Lock { id: lockScreen }

    // qs ipc call popups toggle <audio|wifi>   (opens on the focused monitor)
    // qs ipc call popups close
    IpcHandler {
        target: "popups"
        function toggle(name: string): void {
            PopupState.toggleRequested(name, Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "");
        }
        function close(): void { PopupState.closeAll(); }
    }

    // qs ipc call lock lock      -> lock the session
    // qs ipc call lock preview   -> open the lock screen in a normal window (Esc closes)
    IpcHandler {
        target: "lock"
        function lock(): void { lockScreen.activate(); }
        function preview(): void { lockScreen.password = ""; lockScreen.status = ""; lockScreen.previewing = true; }
        // fill the preview field (only while previewing; for screenshots)
        function previewType(text: string): void { if (lockScreen.previewing) lockScreen.password = text; }
    }
}
