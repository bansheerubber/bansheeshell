import Quickshell
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

    model: ScriptModel {
        values: {
            if (!wifi) {
                return [];
            }

            const networks = Array.from(wifi.networks.values)

            const sortFn = (a, b) => {
                if (b.stateChanging - a.stateChanging) {
                    return b.stateChanging - a.stateChanging;
                } else if (b.connected - a.connected) {
                    return b.connected - a.connected;
                } else if (a.known && !b.known) {
                    return -1;
                } else if (!a.known && b.known) {
                    return 1;
                } else {
                    return b.signalStrength - a.signalStrength;
                }
            };

            return networks.sort(sortFn).filter(Boolean);
        }
    }

    header: BarText {
        bottomPadding: 6 * Theme.controlPanelScale

        text: "Wi-Fi"
        color: Theme.muted
        visible: wifiList.visible
        font.pixelSize: Theme.controlPanelFontSize
        font.family: Theme.controlPanelFontFamily
    }

    // A rescan button right after the networks, then the VPNs under their own
    // heading. All of it scrolls along with the networks.
    footer: Column {
        width: root.width
        topPadding: 8 * Theme.controlPanelScale
        spacing: 6 * Theme.controlPanelScale

        ListButton {
            width: parent.width
            showStatus: false
            changing: rescan.running

            iconUrl: Theme.controlPanelFontFamily != "Ttyp0 OTB" ? "../icons/rescan-wifi.svg" : ""
            iconSize: 10

            text: Theme.controlPanelFontFamily == "Ttyp0 OTB" ? " Rescan" : "Rescan"
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
            font.pixelSize: Theme.controlPanelFontSize
            font.family: Theme.controlPanelFontFamily
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
        text: (modelData && modelData.name) || "Hidden network"
        connected: (modelData && modelData.connected)
        changing: (modelData && modelData.stateChanging)
        onClicked: (modelData && modelData.connected) ? modelData.disconnect() : modelData.connect()
    }
}
