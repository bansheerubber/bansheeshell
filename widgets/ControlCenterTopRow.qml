import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

RowLayout {
    signal weatherOpened()

    Weather {
        id: weatherComponent
        onOpenedInBrowser: weatherOpened()
    }

    Item {
        Layout.fillWidth: true
    }

    Column {
        spacing: 6

        Row {
            Layout.fillWidth: true
            spacing: 6

            SquareButton {
                icon: "../icons/wifi-on.svg"
                onClicked: content.openList = "wifi"
            }

            SquareButton {
                icon: "../icons/bluetooth-on.svg"
                onClicked: content.openList = "bluetooth"
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: 6

            SquareButton {
                icon: "../icons/audio.svg"
                onClicked: content.openList = "audio"
            }

            SquareButton {
                icon: "../icons/ssh.svg"
                onClicked: content.openList = "ssh"
            }
        }
    }
}
