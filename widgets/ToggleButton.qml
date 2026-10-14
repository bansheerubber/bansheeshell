import QtQuick
import QtQuick.Effects
import ".."

// A button that shows whether something is on, highlighted while it is.
Rectangle {
    id: root

    // Icon shown while on and while off.
    property url iconOn
    property url iconOff
    property bool checked: false

    signal toggled()

    width: 40 * Theme.controlPanelScale
    height: 40 * Theme.controlPanelScale
    color: mouse.containsMouse ? "#4A3453"
         : checked ? Theme.workspaceActiveBackground
         : "transparent"

    opacity: enabled ? 1 : 0.5

    Image {
        id: icon
        anchors.centerIn: parent
        source: root.checked ? root.iconOn : root.iconOff
        sourceSize: Qt.size(20 * Theme.controlPanelScale, 20 * Theme.controlPanelScale)
        // Drawn by the overlay below instead, recoloured to match the theme.
        visible: true
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggled()
    }
}
