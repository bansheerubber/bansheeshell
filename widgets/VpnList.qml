import Quickshell
import Quickshell.Io
import QtQuick
import ".."

// VPN connections saved in NetworkManager, read through nmcli because
// Quickshell's Networking module does not cover VPNs.
// Click a VPN to bring it up, or click an active one to take it down.
Column {
    id: root

    // Each entry is { uuid, name, state }, where state is "activated",
    // "activating", "deactivating" or "" when the VPN is down.
    property var vpns: []

    spacing: 0

    Process {
        id: list

        // NAME goes last because it is the only field that can contain colons.
        command: ["nmcli", "--terse", "--fields", "TYPE,STATE,UUID,NAME", "connection", "show"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.vpns = text.split("\n")
                    .map(line => line.match(/^([^:]*):([^:]*):([^:]*):(.*)$/))
                    .filter(match => match && match[1] === "vpn")
                    .map(match => ({
                        state: match[2],
                        uuid: match[3],
                        // nmcli escapes colons and backslashes in terse output.
                        name: match[4].replace(/\\(.)/g, "$1")
                    }));
            }
        }
    }

    // nmcli prints a line here whenever any connection changes, so re-list then.
    Process {
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: refresh.restart()
        }
    }

    // A single change prints several monitor lines in a burst, so wait for it
    // to settle instead of re-listing once per line.
    Timer {
        id: refresh
        interval: 300
        onTriggered: list.running = true
    }

    Repeater {
        model: ScriptModel {
            values: root.vpns
        }

        delegate: ListButton {
            required property var modelData

            width: root.width
            text: modelData.name
            connected: modelData.state === "activated"
            changing: modelData.state === "activating" || modelData.state === "deactivating"
            onClicked: Quickshell.execDetached(["nmcli", "connection",
                connected ? "down" : "up", "uuid", modelData.uuid])
        }
    }
}
