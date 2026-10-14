import QtQuick
import ".."

// A clickable row in the control center's lists: an optional status dot and a
// label. Highlighted while connected, and in the hover colour under the mouse.
Rectangle {
    id: root

    property string text: ""
    property string iconUrl: ""
    property real iconSize: 0

    property int pixelSize: Theme.controlPanelFontSize
    property string family: Theme.controlPanelFontFamily
    property color textColor: Theme.foreground

    property bool connected: false
    // True while connecting, disconnecting or otherwise busy. Clicks are ignored
    // until it finishes.
    property bool changing: false
    // Whether to show the status dot before the label.
    property bool showStatus: true

    signal clicked()

    height: 30 * Theme.controlPanelScale
    color: mouse.containsMouse ? Theme.hoverBackground
         : connected ? Theme.activeBackground
         : "transparent"

    Row {
        id: buttonRow

        width: root.width
        anchors.left: parent.left
        anchors.leftMargin: 8 * Theme.controlPanelScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8 * Theme.controlPanelScale

        // Connected, busy, or neither.
        Rectangle {
            id: buttonStatus

            visible: root.showStatus
            anchors.verticalCenter: parent.verticalCenter
            width: 8 * Theme.controlPanelScale
            height: 8 * Theme.controlPanelScale
            radius: 4 * Theme.controlPanelScale
            color: root.connected ? Theme.connected
                 : root.changing ? Theme.connecting
                 : Theme.notConnected
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconUrl != ""
            source: root.iconUrl
            sourceSize: Qt.size(
                root.iconSize * Theme.controlPanelScale,
                root.iconSize * Theme.controlPanelScale,
            )
        }

        BarText {
            width: root.width
                - 2 * buttonRow.anchors.leftMargin
                - (root.showStatus ? buttonStatus.width + buttonRow.spacing : 0)
            text: root.text
            color: root.textColor
            font.pixelSize: root.pixelSize
            font.family: root.family
            elide: Text.ElideRight
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
