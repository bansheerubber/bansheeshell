import QtQuick
import Qt5Compat.GraphicalEffects
import ".."

// A button that shows whether something is on, highlighted while it is.
Rectangle {
    id: root

    // Icon shown while on and while off.
    property url iconOn
    property url iconOff
    property bool checked: false

    signal toggled()

    width: 40
    height: 40
    color: mouse.containsMouse ? "#4A3453"
         : checked ? Theme.workspaceActiveBackground
         : "transparent"

    opacity: enabled ? 1 : 0.5

    Image {
        id: icon
        anchors.centerIn: parent
        source: root.checked ? root.iconOn : root.iconOff
        sourceSize: Qt.size(20, 20)
        // Drawn by the overlay below instead, recoloured to match the theme.
        visible: false
    }

    ColorOverlay {
        anchors.fill: icon
        source: icon
        color: root.checked ? Theme.workspaceActiveForeground : Theme.muted
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggled()
    }
}
