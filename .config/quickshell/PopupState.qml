pragma Singleton
import QtQuick
import Quickshell

// Lets `qs ipc call popups toggle <name>` reach the bar on the focused monitor.
Singleton {
    signal toggleRequested(string name, string monitor)
    signal closeAll()
}
