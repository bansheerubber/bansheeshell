import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Slider {
    id: slider

    Layout.fillWidth: true

    from: 0.0
    to: 1.0

    signal change(real percent);

    onMoved: {
        change(slider.visualPosition);
    }

    background: Rectangle {
        id: sliderBackground

        y: slider.availableHeight / 2 - height / 2

        width: slider.availableWidth - 2
        height: 4 * Theme.controlPanelScale

        color: "#38263F"

        Rectangle {
            id: sliderFilledBackground

            width: slider.visualPosition * sliderBackground.width
            height: parent.height
            color: "#9D87FF"
        }
    }

    handle: Rectangle {
        id: sliderHandle

        x: slider.visualPosition * (slider.availableWidth - sliderHandle.width)
        implicitWidth: 12 * Theme.controlPanelScale
        implicitHeight: 12 * Theme.controlPanelScale
        width: implicitWidth
        height: implicitHeight

        color: "#7F568F"

        radius: width
    }

    HoverHandler {
        cursorShape: slider.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    }
}
