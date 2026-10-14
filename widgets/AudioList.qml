import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import ".."

// Audio devices in two sections, outputs then inputs. The dot and highlight
// mark the current default device; click another one to make it the default.
// Devices with nothing plugged in, such as an empty HDMI port, are hidden.
Flickable {
    id: root

    // Hardware (and virtual) devices only. Streams are individual apps playing
    // or recording, and nodes without audio are things like cameras.
    readonly property var devices: Pipewire.nodes.values
        .filter(node => node.audio && !node.isStream && !unavailable.includes(node.name))
    readonly property var outputs: devices.filter(node => node.isSink)
    readonly property var inputs: devices.filter(node => !node.isSink)

    function label(node) {
        return node.description || node.nickname || node.name;
    }

    // Names of devices whose port reports "not available". Quickshell's PipeWire
    // service does not expose port availability, so it comes from pactl. A port
    // whose availability is unknown, like built-in speakers, counts as usable.
    property var unavailable: []

    Process {
        id: availability

        // Prints [sinks, sources] as one JSON document.
        command: ["sh", "-c",
            'printf "["; pactl -f json list sinks; printf ","; pactl -f json list sources; printf "]"']
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                // Qt's JavaScript engine has no Array.flat(), so join by hand.
                const [sinks, sources] = JSON.parse(text);
                root.unavailable = sinks.concat(sources)
                    .filter(device => device.ports?.find(port => port.name === device.active_port)
                        ?.availability === "not available")
                    .map(device => device.name);
            }
        }
    }

    // pactl prints a line whenever a card, output or input changes, for example
    // when a monitor or headset is plugged in. Changes to individual app
    // streams are ignored.
    Process {
        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (/ on (card|sink|source) #/.test(line)) {
                    refresh.restart();
                }
            }
        }
    }

    // One plug-in prints several lines in a burst, so wait for it to settle.
    Timer {
        id: refresh
        interval: 300
        onTriggered: availability.running = true
    }

    clip: true
    contentHeight: sections.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: sections
        width: root.width
        spacing: 0

        BarText {
            text: "Output"
            color: Theme.muted
            // The same gap below the heading as under "Wi-Fi" and "VPN".
            bottomPadding: 6
        }

        Repeater {
            model: root.outputs

            delegate: ListButton {
                required property PwNode modelData

                width: sections.width
                text: root.label(modelData)
                connected: modelData === Pipewire.defaultAudioSink
                onClicked: Pipewire.preferredDefaultAudioSink = modelData
            }
        }

        BarText {
            text: "Input"
            color: Theme.muted
            topPadding: 4
            bottomPadding: 6
        }

        Repeater {
            model: root.inputs

            delegate: ListButton {
                required property PwNode modelData

                width: sections.width
                text: root.label(modelData)
                connected: modelData === Pipewire.defaultAudioSource
                onClicked: Pipewire.preferredDefaultAudioSource = modelData
            }
        }
    }
}
