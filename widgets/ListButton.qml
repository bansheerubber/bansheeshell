import QtQuick
import ".."

// A clickable row in the control center's lists: an optional status dot and a
// label. Highlighted while connected, and in the hover colour under the mouse.
Rectangle {
    id: root

    property string text: ""

    property string textIcon: ""
    property url iconUrl: ""
    property real iconSize: 0
    property real iconSpacing: 8

    property int pixelSize: Theme.controlPanelFontSize
    property string family: Theme.controlPanelFontFamily
    property color textColor: Theme.foreground

    property bool connected: false
    property bool changing: false
    property bool showStatus: true

    property bool statusVisible: root.showStatus && (root.connected || root.changing)

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
        spacing: (statusVisible ? 8 : iconSpacing) * Theme.controlPanelScale

        Rectangle {
            id: buttonStatus

            visible: statusVisible
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
            width: root.iconSize * Theme.controlPanelScale
            visible: root.iconUrl == "" && root.textIcon != ""
            text: root.textIcon
            color: root.textColor
            font.pixelSize: root.pixelSize
            font.family: root.family
        }

        BarText {
            width: root.width
                - 2 * buttonRow.anchors.leftMargin
                - (statusVisible ? buttonStatus.width + buttonRow.spacing : 0)
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
        cursorShape: Qt.PointingHandCursor
    }
}
