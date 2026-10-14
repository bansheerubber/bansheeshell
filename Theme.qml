pragma Singleton

import Quickshell
import QtQuick

import "./Client"

Singleton {
    readonly property color background: "#1E121E"
    readonly property color border: "#38263F"
    readonly property color foreground: "#B7ACB7"
    readonly property color muted: "#7C747C"
    readonly property color accent: "#89b4fa"

    readonly property color hoverBackground: "#322238"
    readonly property color activeBackground: "#38263F"
    readonly property color urgent: "#f38ba8"

    readonly property color connected: "#39eF7C"
    readonly property color connecting: "#FFEE53"
    readonly property color notConnected: "#583C63"

    readonly property color workspaceActiveBackground: "#322238"
    readonly property color workspaceActiveForeground: "#B7ACB7"

    readonly property int workspaceExtraWidth: Client.workspaceExtraWidth

    readonly property int barHeight: Client.barHeight
    readonly property int padding: Client.padding
    readonly property int spacing: Client.spacing

    readonly property string fontFamily: Client.fontFamily
    readonly property int fontSize: Client.fontSize

    readonly property string controlPanelFontFamily: Client.controlPanelFontFamily
    readonly property int controlPanelFontSize: Client.controlPanelFontSize
    readonly property real controlPanelScale: Client.controlPanelScale
    readonly property int sftpButtonFontSize: Client.sftpButtonFontSize
}
