import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    Bar {}
    Lock { id: lockScreen }
    Osd {}   // qs ipc call osd brightness | volume
    Notifications {}
    PowerMenu { id: powerMenu; lock: lockScreen }
    Launcher { id: launcher }

    // qs ipc call launcher toggle      -> app launcher (type ">" for symbols)
    // qs ipc call launcher search ">"  -> open straight into the symbol picker
    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle(); }
        // open with a query, e.g. ">" for the symbol picker
        function search(q: string): void { launcher.open = false; launcher.toggle(); launcher.query = q; }
    }

    // qs ipc call power toggle   -> power menu (S sleep, L lock, R reboot, P power off)
    IpcHandler {
        target: "power"
        function toggle(): void { powerMenu.toggle(); }
    }

    // qs ipc call popups toggle <audio|wifi|system>   (opens on the focused monitor)
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
