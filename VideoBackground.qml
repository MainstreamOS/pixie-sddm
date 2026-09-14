import QtQuick
import QtMultimedia

// A moving wallpaper for the greeter, drawn over the still of the same picture.
// It lives in its own file so that a machine without QtMultimedia fails to load
// only this, and still gets the login screen it always had.
Item {
    id: root

    property url videoSource: ""
    // Frames a second to redraw at, 0 for the file's own rate. Set from the
    // desktop's power settings, which leave it in the greeter's state file.
    property int frameRate: 0
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState
    readonly property bool capped: root.playing && root.frameRate > 0

    VideoOutput {
        id: output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        // The still underneath stays visible until there is a frame to cover it,
        // so a video that is slow to start or never starts is never a black screen.
        // Transparent rather than hidden when a cap is on: an item out of the
        // scene is never drawn, and the copy below can only read what is drawn.
        opacity: root.playing && !root.capped ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    // A capped screen shows a copy taken on a timer, so the video decodes as it
    // must while nothing downstream repaints faster than asked for.
    ShaderEffectSource {
        id: cappedFrames
        anchors.fill: parent
        sourceItem: output
        hideSource: false
        live: false
        opacity: root.capped ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    Timer {
        running: root.capped
        interval: Math.max(16, Math.round(1000 / Math.max(1, root.frameRate)))
        repeat: true
        triggeredOnStart: true
        onTriggered: cappedFrames.scheduleUpdate()
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
