import Quickshell.Services.UPower
import QtQuick
import Quickshell
import QtQuick.Layouts
import ".."

RowLayout {
    id: root

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged

    readonly property string changeRate: battery.state === UPowerDeviceState.Charging && battery.changeRate > 1 ? `+${Math.round(battery.changeRate)}W ` : ''

    BarText {
        id: batteryText

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            anchors.bottomMargin: -4
            anchors.topMargin: -8
            anchors.leftMargin: -10
            anchors.rightMargin: -50
        }

        visible: battery.ready && battery.isLaptopBattery
        text: `${changeRate}${Math.round(battery.percentage * 100)}%`
        color: !charging && battery.percentage < 0.15 ? Theme.urgent : Theme.foreground
    }

    PopupWindow {
        id: customTooltip
        anchor.item: batteryText
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.margins.bottom: -5
        anchor.margins.right: -22
        implicitWidth: Math.round(tooltipText.implicitWidth + 50)
        height: 40
        visible: (
            battery.state !== UPowerDeviceState.FullyCharged
            && (battery.timeToFull !== 0 ^ battery.timeToEmpty !== 0)
            && Math.abs(battery.changeRate) > 1
        ) && mouseArea.containsMouse

        Rectangle {
            anchors.fill: parent

            color: Theme.background
            border.color: Theme.border
            border.width: 1.5

            BarText {
                id: tooltipText
                anchors.centerIn: parent
                text: {
                    const hours = Math.floor((charging ? battery.timeToFull : battery.timeToEmpty) / (60 * 60));
                    const minutes = Math.max(
                        Math.floor(
                            ((charging ? battery.timeToFull : battery.timeToEmpty) % (60 * 60)) / 60
                        ),
                        1,
                    );

                    const pluralMinutes = minutes != 1 ? "minutes" : "minute";

                    if (charging) {
                        if (hours !== 0) {
                            return `${hours} hours and ${minutes} ${pluralMinutes} until charged`;
                        } else {
                            return `${minutes} ${pluralMinutes} until charged`;
                        }
                    } else {
                        const changeRate = `-${battery.changeRate.toFixed(1)}W`

                        if (hours !== 0) {
                            return `${hours} hours and ${minutes} ${pluralMinutes} until empty (${changeRate})`;
                        } else {
                            return `${minutes} ${pluralMinutes} until empty (${changeRate})`;
                        }
                    }
                }
            }
        }
    }
}
