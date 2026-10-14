import Quickshell
import QtQuick

BarText {
    text: `${Qt.formatDateTime(clock.date, "dddd d MMM, hh:mm AP")} - nearly quittin' time`

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
