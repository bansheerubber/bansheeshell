import Quickshell
import QtQuick
import QtQuick.Layouts
import "widgets"

PanelWindow {
    id: bar

    surfaceFormat {
        opaque: false
    }

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

    // Right side
    RowLayout {
        id: rightSide
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing

        BarText {
            text: "☰"
        }

        Volume {}

        PolybarWatcher {
            port: 15310
            command: "python /home/me/.local/scripts/audio.py get-sink-source"
        }

        Battery {}
    }

    MouseArea {
        id: rightSideClick
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: rightSide.left
        anchors.right: rightSide.right
        anchors.leftMargin: -50
        onClicked: controlCenter.toggle()
    }
}
