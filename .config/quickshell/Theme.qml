pragma Singleton
import QtQuick
import Quickshell

// Colors / sizes shared by the bar, overlays and lock screen. Tweak here.
Singleton {
    readonly property color bg: "#151515"        // same as the bar
    readonly property color bgAlt: "#1c1c1c"     // inner boxes (calendar grid, album art)
    readonly property color hover: "#2a2a2a"
    readonly property color fg: "#f2f2f2"
    readonly property color dim: "#6b6b6b"
    readonly property color green: "#1dd79d"      // hyprland active_border; lock screen + battery full
    readonly property color amber: "#ffbf00"     // lock screen: authenticating
    readonly property color buttonBg: "#1c1c1c"  // filled buttons (play/pause); same as bgAlt for now
    readonly property color border: "#3a3a3a"
    readonly property color panel: "#262626"     // sections inside the system overlay

    // bar (from the old waybar style.css)
    readonly property int barHeight: 21
    readonly property color barHover: "#5c5c5c"
    readonly property color blue: "#0866ee"      // bluetooth
    readonly property color cyan: "#07dcc7"      // charging
    readonly property color red: "#d91e58"       // low battery
    readonly property color orange: "#f75806"    // muted / disconnected

    // Nerd Font glyphs above U+FFFF can't be written as \uXXXX
    function g(cp) { return String.fromCodePoint(cp); }

    // "Alder Lake ... Controller Speaker (Stereo)" -> "Speaker"
    function sinkName(n) {
        if (!n) return "";
        let s = n.description || n.nickname || n.name;
        return s.replace(/^.*Controller\s+/, "").replace(/\s*\((Stereo|Mono)\)$/, "");
    }

    readonly property string font: "RobotoMono Nerd Font"
    readonly property int fontSize: 14

    readonly property int padding: 14
    readonly property int gap: 6                  // space between bar item and tooltip
    readonly property int cut: 14                 // outward cut corner where an overlay meets the bar
}
