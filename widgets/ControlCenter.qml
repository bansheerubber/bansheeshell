import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// A popup that hangs just below whichever bar item it is anchored to.
// It starts hidden; call `toggle()` to show it. Clicking outside closes it.
PopupWindow {
    id: root

    implicitWidth: 300 * Theme.controlPanelScale
    // Fits the buttons plus whichever list is open, up to a cap; past that the
    // list scrolls. The 16 covers the content's margins on both sides.
    implicitHeight: Math.min(content.implicitHeight + 16 * Theme.controlPanelScale, 600 * Theme.controlPanelScale)
    
    visible: false
    color: "transparent"

    grabFocus: true

    onVisibleChanged: {
        if (!visible) {
            content.openList = "wifi";
        }
    }

    function toggle() {
        if (visible) {
            visible = false;
        } else {
            visible = true;
        }
    }

    // Open below the anchored item with their right edges lined up, growing
    // downwards and to the left.
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    // A small gap below the bar and in from the screen's right edge. Margins move
    // the edges of the area the popup attaches to, and it attaches to the bottom
    // edge, so the bottom margin is what moves it. It is negative to push that
    // edge down rather than pull it up.
    anchor.margins.bottom: -3
    anchor.margins.right: 4

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.border
        border.width: 1.5

        // A layout rather than a Column, so a list can shrink to fit when the
        // popup reaches its height cap.
        ColumnLayout {
            id: content

            // Which list is open: "wifi", "bluetooth", "ssh" or "audio". Only one
            // shows at a time, and Wi-Fi is the one shown on opening.
            property string openList: "wifi"

            anchors.fill: parent
            anchors.margins: 8 * Theme.controlPanelScale
            spacing: 6 * Theme.controlPanelScale

            ControlCenterTopRow {
                onWeatherOpened: root.visible = false
            }

            WifiList {
                id: wifiList
                visible: content.openList === "wifi"
                Layout.fillWidth: true
                // Asks for its full height, but shrinks to fit when the popup is capped.
                Layout.preferredHeight: contentHeight
                Layout.fillHeight: true
            }

            BluetoothList {
                id: bluetoothList
                visible: content.openList === "bluetooth"
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.fillHeight: true
            }

            AudioList {
                visible: content.openList === "audio"
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.fillHeight: true
            }

            SshList {
                id: sshList
                visible: content.openList === "ssh"
                // Get out of the way of the new terminal.
                onSshOpened: root.visible = false
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.fillHeight: true
            }
        }
    }
}
