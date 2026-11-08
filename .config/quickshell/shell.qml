import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    Bar {}

    // qs ipc call popups toggle <audio|wifi>   (opens on the focused monitor)
    // qs ipc call popups close
    IpcHandler {
        target: "popups"
        function toggle(name: string): void {
            PopupState.toggleRequested(name, Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "");
        }
        function close(): void { PopupState.closeAll(); }
    }
}
