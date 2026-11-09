import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

ColumnLayout {
    id: media
    spacing: 8

    readonly property int artSize: 170

    function isSpotify(p) {
        return (p.identity || "").toLowerCase().includes("spotify")
            || (p.dbusName || "").toLowerCase().includes("spotify");
    }

    // playing (spotify first) -> spotify -> anything
    readonly property var player: {
        const ps = Mpris.players.values;
        if (!ps || ps.length === 0) return null;
        const playing = ps.filter(p => p.isPlaying);
        return playing.find(isSpotify) ?? playing[0] ?? ps.find(isSpotify) ?? ps[0];
    }

    Rectangle {
        Layout.preferredWidth: media.artSize
        Layout.preferredHeight: media.artSize
        color: Theme.bgAlt
        border.color: Theme.border
        border.width: 1
        clip: true

        Image {
            id: art
            anchors.fill: parent
            anchors.margins: 1
            source: media.player ? (media.player.trackArtUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.width: media.artSize * 2
            sourceSize.height: media.artSize * 2
            visible: status === Image.Ready
        }
        StyledText {
            anchors.centerIn: parent
            visible: art.status !== Image.Ready
            text: "" // music note
            font.pixelSize: 48
            color: Theme.dim
        }
    }

    StyledText {
        text: media.player ? (media.player.trackTitle || "Unknown title") : "Nothing playing"
        font.weight: Font.Bold
        elide: Text.ElideRight
        Layout.preferredWidth: media.artSize
        horizontalAlignment: Text.AlignHCenter
    }
    StyledText {
        text: media.player ? (media.player.trackArtist || media.player.identity || "") : ""
        visible: text !== ""
        color: Theme.dim
        font.pixelSize: 12
        elide: Text.ElideRight
        Layout.preferredWidth: media.artSize
        horizontalAlignment: Text.AlignHCenter
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 10

        IconButton {
            text: "" // step-backward
            enabled: media.player !== null && media.player.canGoPrevious
            onClicked: media.player.previous()
        }
        IconButton {
            size: 38
            glyphSize: 16
            text: media.player && media.player.isPlaying ? "" : "" // pause / play
            filled: true
            enabled: media.player !== null && media.player.canTogglePlaying
            onClicked: media.player.togglePlaying()
        }
        IconButton {
            text: "" // step-forward
            enabled: media.player !== null && media.player.canGoNext
            onClicked: media.player.next()
        }
    }
}
