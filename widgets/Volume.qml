import Quickshell.Services.Pipewire
import QtQuick
import ".."

BarText {
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: Boolean(sink?.audio)

    visible: ready
    text: !ready ? ""
        : sink.audio.muted ? "muted"
        : `${Math.round(sink.audio.volume * 100)}%`

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // Scrolling changes the volume. Clicks are not taken, so they fall through to
    // the bar underneath, which opens the control center.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            parent.sink.audio.volume = Math.max(0, Math.min(1, parent.sink.audio.volume + step));
        }
    }
}
