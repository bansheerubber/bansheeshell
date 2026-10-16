import Quickshell
import QtQuick
import ".."

BarText {
    text: `${Qt.formatDateTime(clock.date, "dddd d MMM, hh:mm AP")}${Theme.clockSuffix}`

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
