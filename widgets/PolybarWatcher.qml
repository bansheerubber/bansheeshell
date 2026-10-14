import Quickshell.Io
import QtQuick

BarText {
    id: root

    property int port: 0
    property string command: ""
    property string file: ""

    visible: text.trim() !== ""

    Component.onCompleted: watcher.running = root.file !== "" || root.port > 0

    Process {
        id: watcher

        command: root.file !== ""
            ? ["polybar-watcher", "watch", root.file]
            : ["polybar-watcher", "listen", String(root.port), root.command]

        stdout: SplitParser {
            onRead: line => root.text = line.replace(/%\{[^}]*\}/g, "")
        }

        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 2000
        onTriggered: watcher.running = true
    }
}
