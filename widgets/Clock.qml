import Quickshell
import QtQuick

BarText {
    text: `${Qt.formatDateTime(clock.date, "dddd d MMM, hh:mm AP")}`

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
