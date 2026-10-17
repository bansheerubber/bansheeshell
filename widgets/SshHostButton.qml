import QtQuick
import ".."

// One host in the SSH list. Clicking the row sends `clicked`, and the "F" button
// at its right end sends `filesClicked`.
ListButton {
    id: root

    signal filesClicked()

    showStatus: false

    // Declared after the row's own click area, so it sits on top and gets its
    // clicks first.
    Rectangle {
        anchors.right: parent.right
        width: parent.height
        height: parent.height
        // Painted in the panel background rather than left transparent, so the
        // row's hover colour does not show through it.
        color: filesMouse.containsMouse ? Theme.hoverBackground : Theme.background

        BarText {
            anchors.centerIn: parent
            text: ""
            font.pixelSize: Theme.sftpButtonFontSize
        }

        MouseArea {
            id: filesMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.filesClicked()
            cursorShape: Qt.PointingHandCursor
        }
    }
}
