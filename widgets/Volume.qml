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
}
