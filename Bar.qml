import Quickshell
import QtQuick
import QtQuick.Layouts
import "widgets"

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.background

    // Left side
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing

        Workspaces {
            screen: bar.screen
        }

        NiriMap {
            screenName: bar.screen.name
        }

        PolybarWatcher {
            file: "/home/me/Projects/bansheeshare2/upload-debris"
        }
    }

    Clock {
        anchors.centerIn: parent
    }

    ControlCenter {
        id: controlCenter
        anchor.window: bar
        anchor.item: rightSideClick
    }

    // Clicking anywhere on the right side opens the control center, and clicking
    // again closes it. Declared before the row so it sits underneath: widgets
    // with their own click handling, like Volume, still get their clicks.
    // It spans the bar's full height, not just the row's, which is only as tall
    // as its text.
    MouseArea {
        id: rightSideClick
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: rightSide.left
        anchors.right: rightSide.right
        onClicked: controlCenter.toggle()
    }

    // Right side
    RowLayout {
        id: rightSide
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing

        Volume {}

        PolybarWatcher {
            port: 15310
            command: "python /home/me/.local/scripts/audio.py get-sink-source"
        }

        Battery {}
    }
}
