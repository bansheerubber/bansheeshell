import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import ".."

// Bluetooth devices known to the default adapter: connected first, then paired,
// then by name. Click a device to connect to it, or click a connected one to
// disconnect. Nothing earbuds show the left bud, right bud and case separately.
ListView {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    // Reads per-bud battery levels from Nothing earbuds, which BlueZ cannot do.
    readonly property string budBatteryScript:
        Qt.resolvedUrl("../scripts/nothing-ear-battery.py").toString().replace(/^file:\/\//, "")

    clip: true
    spacing: 0

    model: ScriptModel {
        values: !adapter ? [] : Array.from(adapter.devices.values)
            .sort((a, b) => (b.connected - a.connected)
                || (b.paired - a.paired)
                || a.name.localeCompare(b.name))
    }

    delegate: ListButton {
        id: entry

        required property BluetoothDevice modelData

        readonly property bool isNothingEar: modelData.name.startsWith("Nothing")
        // The latest reading from the helper script, such as
        // { left: 50, right: 40, case: 100 }. A bud that has run flat or a closed
        // case is simply missing, and a failed reading is {}.
        property var budLevels: ({})

        // "L 50%  R 40%  C 100%" with whatever parts were reported, or BlueZ's
        // single level when there is no per-bud reading.
        readonly property string batteryText: {
            const parts = [["left", "L"], ["right", "R"], ["case", "C"]]
                .filter(([key]) => budLevels[key] !== undefined)
                .map(([key, letter]) => `${letter} ${budLevels[key]}%`);
            if (connected && parts.length > 0) {
                return parts.join(" ");
            }
            return modelData.batteryAvailable ? `${Math.round(modelData.battery * 100)}%` : "";
        }

        width: ListView.view.width
        text: (modelData.name || modelData.address) + (batteryText ? ` ${batteryText}` : "")
        connected: modelData.connected
        changing: modelData.pairing
            || modelData.state === BluetoothDeviceState.Connecting
            || modelData.state === BluetoothDeviceState.Disconnecting
        onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()

        Process {
            id: budBattery
            command: [root.budBatteryScript, entry.modelData.address]

            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        entry.budLevels = JSON.parse(text);
                    } catch (error) {
                        entry.budLevels = {};
                    }
                }
            }
        }

        // Read the buds when the list opens, then once a minute while it is shown.
        Timer {
            interval: 60000
            repeat: true
            triggeredOnStart: true
            running: entry.isNothingEar && entry.modelData.connected && root.visible
            onTriggered: if (!budBattery.running) budBattery.running = true
        }
    }
}
