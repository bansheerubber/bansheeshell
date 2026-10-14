import Quickshell
import Quickshell.WindowManager
import QtQuick
import ".."

Row {
    id: root

    required property ShellScreen screen

    Repeater {
        model: Array.from(WindowManager.screenProjection(root.screen).windowsets)
            .sort((a, b) => {
                let aNumber = parseInt(a.name.replace(/[^0-9]/g, ''));
                let bNumber = parseInt(b.name.replace(/[^0-9]/g, ''));

                return aNumber - bNumber;
            }).filter((workspace) => workspace.active || Niri.activeWindowId(workspace))

        delegate: Rectangle {
            required property Windowset modelData

            visible: modelData.shouldDisplay
            width: label.implicitWidth + Theme.workspaceExtraWidth
            height: Theme.barHeight
            color: modelData.active ? Theme.workspaceActiveBackground : "transparent"

            BarText {
                id: label
                anchors.centerIn: parent
                text: parent.modelData.name
                color: parent.modelData.urgent ? Theme.urgent
                     : Theme.foreground
            }
        }
    }
}
