import Quickshell.Services.UPower
import QtQuick
import ".."

BarText {
    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged

    readonly property string changeRate: battery.state === UPowerDeviceState.Charging && battery.changeRate > 1 ? `+${Math.round(battery.changeRate)}W ` : ''

    rightPadding: 4

    visible: battery.ready && battery.isLaptopBattery
    text: `${changeRate}${Math.round(battery.percentage * 100)}%`
    color: !charging && battery.percentage < 0.15 ? Theme.urgent : Theme.foreground
}
