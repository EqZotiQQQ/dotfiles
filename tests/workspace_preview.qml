import QtQuick
import QtTest
import Quickshell
import qs.bar
import qs.common
import qs.fixtures

ShellRoot {
    HyprlandMonitor { id: testMonitor; activeWorkspace: first }
    HyprlandWorkspace { id: first; monitor: testMonitor }
    HyprlandWorkspace { id: second; monitor: testMonitor; Component.onCompleted: this.id = 2 }
    HyprlandToplevel {
        id: firstWindow
        workspace: first
        lastIpcObject: ({at: [80, 120], size: [640, 360], floating: false, hidden: false})
    }
    HyprlandToplevel {
        id: otherWindow
        workspace: second
        lastIpcObject: ({at: [0, 0], size: [800, 600], floating: false, hidden: false})
    }
    HyprlandToplevel {
        id: hiddenWindow
        workspace: first
        lastIpcObject: ({at: [0, 0], size: [800, 600], floating: false, hidden: true})
    }

    FloatingWindow {
        id: window
        visible: true
        implicitWidth: 800
        implicitHeight: 600

        Workspaces {
            id: workspaces
            x: 30
            y: 30
            monitor: testMonitor
        }

        TestCase {
            name: "WorkspacePreview"
            when: window.visible
            onCompletedChanged: if (completed) Qt.quit()

            function check(condition, message) {
                if (!condition) {
                    console.error("ASSERTION", message);
                    fail(message);
                }
            }

            function tile(workspace) {
                return workspaces.children.find(c => c.modelData === workspace);
            }

            function leave() {
                mouseMove(window.contentItem, 700, 500);
            }

            function windowTiles(item) {
                let result = item.modelData instanceof HyprlandToplevel ? [item] : [];
                for (const child of item.children)
                    result = result.concat(windowTiles(child));
                return result;
            }

            function init() {
                workspaces.visible = false;
                Theme.json = {bar: {position: "top"}, motion: {durationMs: 0}};
                Hyprland.workspaces.values = [first, second];
                Hyprland.toplevels.values = [];
                first.activations = 0;
                second.activations = 0;
                leave();
                wait(50);
                workspaces.visible = true;
                wait(50);
            }

            function test_hover_delay_and_leave() {
                mouseMove(tile(first));
                wait(250);
                check(!workspaces.previewTile, "preview must wait 400 milliseconds");
                wait(250);
                check(workspaces.previewTile === tile(first), "400-millisecond hover opens the selected workspace");
                check(first.activations === 0, "hover does not activate the workspace");
                leave();
                wait(50);
                check(!workspaces.previewTile, "leaving closes the preview");
                console.log("WORKSPACE_PREVIEW_PASSED");
            }

            function test_leave_cancels_pending_hover() {
                mouseMove(tile(first));
                wait(250);
                leave();
                wait(250);
                check(!workspaces.previewTile, "leaving cancels the pending preview");
                console.log("WORKSPACE_PREVIEW_PASSED");
            }

            function test_right_click_and_left_click() {
                for (const edge of ["top", "bottom", "left", "right"]) {
                    Theme.json = {bar: {position: edge}, motion: {durationMs: 0}};
                    wait(50);
                    mouseMove(tile(second));
                    mouseClick(tile(second), undefined, undefined, Qt.RightButton);
                    wait(50);
                    check(workspaces.previewTile === tile(second), "right click opens immediately at " + edge);
                    check(second.activations === 0, "right click does not switch workspace");
                    mouseClick(tile(second), undefined, undefined, Qt.RightButton);
                    check(!workspaces.previewTile, "second right click closes preview at " + edge);
                    wait(500);
                    check(!workspaces.previewTile, "hover does not reopen preview after closing by right click");
                    check(second.activations === 0, "closing preview does not switch workspace");
                    mouseClick(tile(second), undefined, undefined, Qt.RightButton);
                    check(workspaces.previewTile === tile(second), "next right click reopens preview");
                    mouseClick(tile(second));
                    check(second.activations === 1, "left click still activates workspace");
                    check(!workspaces.previewTile, "activation closes preview");
                    second.activations = 0;
                    leave();
                }
                console.log("WORKSPACE_PREVIEW_PASSED");
            }

            function test_switch_tiles_restarts_delay() {
                mouseMove(tile(first));
                wait(250);
                mouseMove(tile(second));
                wait(250);
                check(!workspaces.previewTile, "time on another tile does not count");
                wait(250);
                check(workspaces.previewTile === tile(second), "preview belongs to the newly hovered tile");
                console.log("WORKSPACE_PREVIEW_PASSED");
            }

            function test_hiding_bar_closes_preview() {
                mouseMove(tile(first));
                mouseClick(tile(first), undefined, undefined, Qt.RightButton);
                wait(50);
                check(workspaces.previewTile === tile(first), "preview is open before hiding bar");
                workspaces.visible = false;
                wait(50);
                check(!workspaces.previewTile, "hiding bar closes preview and releases captures");
                workspaces.visible = true;
                console.log("WORKSPACE_PREVIEW_PASSED");
            }

            function test_preview_contents_and_capture_lifetime() {
                Hyprland.toplevels.values = [firstWindow, otherWindow, hiddenWindow];
                const refreshes = Hyprland.refreshes;
                mouseMove(tile(first));
                mouseClick(tile(first), undefined, undefined, Qt.RightButton);
                wait(100);
                const loader = workspaces.resources.find(r => r instanceof LazyLoader);
                check(loader && loader.item && loader.item.visible, "popup is loaded and visible");
                const preview = loader.item;
                check(preview.anchor.item === tile(first), "popup is anchored to the selected tile");
                check(Hyprland.refreshes > refreshes, "opening refreshes window geometry");
                const windows = windowTiles(preview.contentItem);
                check(windows.length === 1 && windows[0].modelData === firstWindow,
                      "preview excludes hidden windows and other workspaces");
                check(Math.abs(windows[0].width - 640 * preview.zoom) < 0.01,
                      "window size is scaled to the preview");
                check(Math.abs(windows[0].x - (80 - preview.screen.x) * preview.zoom) < 0.01,
                      "window position uses screen-relative coordinates");
                leave();
                wait(50);
                check(!loader.item, "closing destroys the popup and its captures");
                console.log("WORKSPACE_PREVIEW_PASSED");
            }
        }
    }
}
