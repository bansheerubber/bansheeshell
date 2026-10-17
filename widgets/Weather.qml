import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

RowLayout {
    id: weather

    spacing: 3 * Theme.controlPanelScale

    visible: WeatherFetcher.icon != ""

    signal openedInBrowser()

    Image {
        source: `../icons/weather/${WeatherFetcher.icon}.svg`
        sourceSize: Qt.size(80 * Theme.controlPanelScale, 80 * Theme.controlPanelScale)
    }

    Column {
        BarText {
            topPadding: -5 * Theme.controlPanelScale
            text: `${WeatherFetcher.temperature}°`
            font.pixelSize: 40 * Theme.controlPanelScale
            font.family: "Noto Sans"
            font.weight: 550
            color: Theme.foregroundBold
        }

        BarText {
            topPadding: -6 * Theme.controlPanelScale
            text: "Seattle"
            font.pixelSize: 15 * Theme.controlPanelScale
            font.family: "Noto Sans"
            color: Theme.foreground
        }
    }

    TapHandler {
        onTapped: {
            Qt.openUrlExternally("https://www.google.com/search?q=seattle+weather")
            focusChrome.running = true;
            openedInBrowser();
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: focusChrome
        command: ["/home/me/.local/scripts/focus-chrome.sh"]
    }
}
