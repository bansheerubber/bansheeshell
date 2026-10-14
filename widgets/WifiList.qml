import Quickshell.Io
import Quickshell.Networking
import QtQuick
import ".."

// Nearby Wi-Fi networks: any that are connecting or disconnecting first, then
// the connected one, then the rest by strongest signal, followed by the saved
// VPNs. Click an entry to connect to it, or click a connected one
// to disconnect.
ListView {
    id: root

    readonly property WifiDevice wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null

    clip: true
    spacing: 0

    model: !wifi ? [] : Array.from(wifi.networks.values)
        .sort((a, b) => (b.stateChanging - a.stateChanging)
            || (b.connected - a.connected)
            || (b.signalStrength - a.signalStrength))

    // A rescan button right after the networks, then the VPNs under their own
    // heading. All of it scrolls along with the networks.
    footer: Column {
        width: root.width
        topPadding: 8
        spacing: 6

        ListButton {
            width: parent.width
            showStatus: false
            changing: rescan.running
            text: " Rescan"
            textColor: Theme.foreground
            onClicked: rescan.running = true

            // Quickshell has no rescan call, so ask NetworkManager directly.
            // Unlike connecting, scanning is allowed without a password.
            Process {
                id: rescan
                command: ["nmcli", "device", "wifi", "rescan"]
            }
        }

        BarText {
            text: "VPN"
            color: Theme.muted
        }

        VpnList {
            width: parent.width
        }
    }

    // The network list only fills in while the device is scanning. Scan only
    // while the list is shown.
    Binding {
        target: root.wifi
        property: "scannerEnabled"
        value: true
        when: root.wifi !== null && root.visible
    }

    delegate: ListButton {
        required property WifiNetwork modelData

        width: ListView.view.width
        text: modelData.name || "Hidden network"
        connected: modelData.connected
        changing: modelData.stateChanging
        onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
    }
}
