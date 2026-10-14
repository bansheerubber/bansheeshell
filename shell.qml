//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR = 0
//@ pragma Env QT_SCALE_FACTOR = 0.78

import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
