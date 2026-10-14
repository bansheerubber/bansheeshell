import QtQuick
import ".."

// A clickable row in the control center's lists: an optional status dot and a
// label. Highlighted while connected, and in the hover colour under the mouse.
Rectangle {
    id: root

    property string text: ""
    property color textColor: Theme.foreground
    property bool connected: false
    // True while connecting, disconnecting or otherwise busy. Clicks are ignored
    // until it finishes.
    property bool changing: false
    // Whether to show the status dot before the label.
    property bool showStatus: true

    signal clicked()

    height: 30
    color: mouse.containsMouse ? Theme.hoverBackground
         : connected ? Theme.activeBackground
         : "transparent"

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Connected, busy, or neither.
        Rectangle {
            visible: root.showStatus
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: root.connected ? Theme.connected
                 : root.changing ? Theme.connecting
                 : Theme.notConnected
        }

        BarText {
            text: root.text
            color: root.textColor
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.changing
        onClicked: root.clicked()
    }
}
