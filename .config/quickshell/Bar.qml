import QtQuick
import Quickshell
import Quickshell.Wayland

// One bar per monitor: workspaces | clock | bluetooth volume wifi battery
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors { top: true; left: true; right: true }
        implicitHeight: Theme.barHeight
        color: Theme.bg
        WlrLayershell.namespace: "quickshell-bar"

        Workspaces {
            screen: bar.modelData
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Clock {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            BluetoothItem {}
            VolumeItem { id: vol; peers: [net, bat] }
            NetworkItem { id: net; peers: [vol, bat] }
            BatteryItem { id: bat; peers: [vol, net] }
        }
    }
}
