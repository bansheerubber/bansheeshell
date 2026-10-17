import QtQuick
import QtQuick.Effects
import ".."

// A button that shows whether something is on, highlighted while it is.
Rectangle {
    id: root

    property url icon

    signal clicked()

    width: 40 * Theme.controlPanelScale
    height: 40 * Theme.controlPanelScale
    color: mouse.containsMouse ? "#4A3453" : Theme.workspaceActiveBackground

    opacity: enabled ? 1 : 0.5

    Image {
        id: icon
        anchors.centerIn: parent
        source: root.icon
        sourceSize: Qt.size(20 * Theme.controlPanelScale, 20 * Theme.controlPanelScale)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
