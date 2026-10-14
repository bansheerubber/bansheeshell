import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import ".."

// Machines to SSH into, read from /etc/hosts and split into two sections:
// LAN (10.0.0.x), shown only while the wired LAN adapter is connected, and
// WAN (10.1.x.x), always shown.
Flickable {
    id: root

    // The wired adapter that puts this machine on the LAN.
    readonly property string lanDeviceName: "enp7s0u2u4"
    readonly property bool lanConnected: Networking.devices.values
        .some(d => d.name === lanDeviceName && d.connected)

    // Each entry is { address, name }, using the first hostname on the line.
    property var hosts: []
    readonly property var lanHosts: hosts.filter(h => h.address.startsWith("10.0.0."))
    readonly property var wanHosts: hosts.filter(h => h.address.startsWith("10.1."))

    // Opens a terminal with an SSH session to the host. niri spawns it, so the
    // terminal belongs to the session rather than to the bar. When the SSH
    // session ends, the terminal carries on with a local shell instead of
    // closing. The hostname is passed as an argument rather than pasted into
    // the script, so no hostname can be misread as shell syntax.
    function connect(hostname) {
        Quickshell.execDetached(["niri", "msg", "action", "spawn", "--",
            "alacritty", "-e", "sh", "-c", 'ssh "$1"; exec "${SHELL:-bash}"', "sh", hostname]);
        sshOpened();
    }

    // Opens Thunar on the host's files over SFTP. Like the terminal, niri
    // spawns it so it outlives the bar.
    function openFiles(hostname) {
        Quickshell.execDetached(["niri", "msg", "action", "spawn", "--",
            "thunar", `sftp://${hostname}/`]);
        sshOpened();
    }

    // Sent after a terminal or file manager has been opened for a host.
    signal sshOpened()

    clip: true
    contentHeight: sections.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    FileView {
        path: "/etc/hosts"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.hosts = text().split("\n")
                .map(line => line.replace(/#.*/, "").trim().split(/\s+/))
                .filter(fields => fields.length >= 2)
                .map(fields => ({ address: fields[0], name: fields[1] }));
        }
    }

    Column {
        id: sections
        width: root.width
        spacing: 0

        BarText {
            text: "LAN"
            color: Theme.muted
            // The same gap below the heading as under "Wi-Fi" and "VPN".
            bottomPadding: 6
            visible: root.lanConnected
        }

        Repeater {
            model: root.lanConnected ? root.lanHosts : []

            delegate: SshHostButton {
                required property var modelData

                width: sections.width
                text: modelData.name
                onClicked: root.connect(modelData.name)
                onFilesClicked: root.openFiles(modelData.name)
            }
        }

        BarText {
            text: "WAN"
            color: Theme.muted
            // Space between the sections when LAN is shown above.
            topPadding: root.lanConnected ? 4 : 0
            bottomPadding: 6
        }

        Repeater {
            model: root.wanHosts

            delegate: SshHostButton {
                required property var modelData

                width: sections.width
                text: modelData.name
                onClicked: root.connect(modelData.name)
                onFilesClicked: root.openFiles(modelData.name)
            }
        }
    }
}
