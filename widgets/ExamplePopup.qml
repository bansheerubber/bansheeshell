import Quickshell
import QtQuick
import ".."

// An example popup that hangs just below whichever bar item it is anchored to.
// It is always shown; bind `visible` to something to show it on demand.
PopupWindow {
    implicitWidth: 220
    implicitHeight: 60
    visible: true
    color: "transparent"

    // Open below the anchored item, growing downwards.
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 4

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.background
        border.color: Theme.accent

        BarText {
            anchors.centerIn: parent
            text: "Hello from a popup"
        }
    }
}
