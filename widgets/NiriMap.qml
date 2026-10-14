import Quickshell.Io
import QtQuick

Image {
    id: root

    required property string screenName
    readonly property string path: `/home/me/.local/share/bansheeniri/map.${screenName}.png`

    property int version: 0

    source: `file://${path}?v=${version}`
    cache: false
    smooth: false

    FileView {
        path: root.path
        watchChanges: true
        onFileChanged: root.version++
    }
}
