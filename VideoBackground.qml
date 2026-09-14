import QtQuick
import QtMultimedia

// A moving wallpaper for the greeter, drawn over the still of the same picture.
// It lives in its own file so that a machine without QtMultimedia fails to load
// only this, and still gets the login screen it always had.
Item {
    id: root

    property url videoSource: ""
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState

    VideoOutput {
        id: output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        // The still underneath stays visible until there is a frame to cover it,
        // so a video that is slow to start or never starts is never a black screen.
        opacity: root.playing ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    MediaPlayer {
        id: player
        videoOutput: output
        source: root.videoSource
        loops: MediaPlayer.Infinite
        // Nobody is at the login screen to hear a wallpaper.
        audioOutput: null
        onSourceChanged: if (root.videoSource != "") play()
        onErrorOccurred: stop()
    }
}
