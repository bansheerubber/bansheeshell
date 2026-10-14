pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property var workspaces: []

    function activeWindowId(windowset) {
        const ws = workspaces.find(w => w.name === windowset.name);
        return ws?.active_window_id ?? null;
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                const event = JSON.parse(line);
                if (event.WorkspacesChanged) {
                    workspaces = event.WorkspacesChanged.workspaces;
                } else if (event.WorkspaceActiveWindowChanged) {
                    const change = event.WorkspaceActiveWindowChanged;
                    workspaces = workspaces.map(w => w.id === change.workspace_id
                        ? Object.assign({}, w, { active_window_id: change.active_window_id })
                        : w);
                }
            }
        }
    }
}
