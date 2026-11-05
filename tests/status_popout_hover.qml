import QtQuick
import QtQuick.Window
import QtTest
import Quickshell
import qs.bar
import qs.common

ShellRoot {
    Window {
        id: window
        visible: true
        width: 1600
        height: 1000

        StatusIsland {
            id: status
            x: parent.width - width
            y: 0
        }

        TestCase {
            name: "StatusPopoutHover"
            when: window.visible
            onCompletedChanged: if (completed) Qt.quit()

            function check(condition, message) {
                if (!condition) {
                    console.error("ASSERTION", message);
                    fail(message);
                }
            }

            function chip(icon) {
                return status.children.find(c => c instanceof Grid).children.find(c => c.icon === icon);
            }

            function edgeAbove(module) {
                const point = module.mapToItem(window.contentItem, module.width / 2, 0);
                mouseMove(window.contentItem, point.x, 0);
            }

            function openCpu() {
                mouseMove(chip(Icons.cpu));
                wait(320);
                check(status.open === "cpu", "hover opens CPU without pinning it");
                check(status.pinned === "", "hover stays unpinned");
            }

            function init() {
                status.close();
                mouseMove(window.contentItem, 1, window.height - 1);
                Theme.json = {bar: {position: "top", flush: true}, motion: {durationMs: 120}};
                wait(200);
            }

            function test_top_edge_closes_after_delay() {
                openCpu();
                edgeAbove(chip(Icons.cpu));
                wait(150);
                check(status.open === "cpu", "leaving does not close immediately");
                wait(300);
                check(status.open === "", "stationary pointer at the top edge closes CPU");
                wait(200);
                check(status.panel.children[0].item === null, "closing unloads CPU content");
                check(status.open === "", "staying at the edge does not reopen CPU");
                console.log("POPOUT_HOVER_PASSED");
            }

            function test_brushing_chip_does_not_open_at_edge() {
                mouseMove(chip(Icons.cpu));
                wait(30);
                edgeAbove(chip(Icons.cpu));
                wait(200);
                check(status.open === "", "leaving the chip cancels its pending hover open");
                console.log("POPOUT_HOVER_PASSED");
            }

            function test_entering_panel_keeps_it_open() {
                openCpu();
                const cpu = chip(Icons.cpu);
                mouseMove(cpu, cpu.width / 2, cpu.height + 2);
                wait(100);
                mouseMove(status.panel);
                wait(450);
                check(status.open === "cpu", "crossing the gap into the panel cancels closing");
                mouseMove(window.contentItem, 1, window.height - 1);
                wait(450);
                check(status.open === "", "leaving the expanded panel closes it");
                console.log("POPOUT_HOVER_PASSED");
            }

            function test_returning_to_chip_cancels_closing() {
                openCpu();
                edgeAbove(chip(Icons.cpu));
                wait(180);
                mouseMove(chip(Icons.cpu));
                wait(450);
                check(status.open === "cpu", "returning to the chip cancels closing");
                console.log("POPOUT_HOVER_PASSED");
            }

            function test_switching_chips_then_leaving() {
                openCpu();
                mouseMove(chip(Icons.thermometer));
                wait(160);
                check(status.open === "temp", "hover switches to temperature");
                edgeAbove(chip(Icons.thermometer));
                wait(450);
                check(status.open === "", "leaving the new chip closes its panel");
                console.log("POPOUT_HOVER_PASSED");
            }

            function test_click_pins_until_clicked_again() {
                openCpu();
                mouseClick(chip(Icons.cpu));
                edgeAbove(chip(Icons.cpu));
                wait(500);
                check(status.open === "cpu" && status.pinned === "cpu", "explicitly pinned panel stays open");
                mouseMove(chip(Icons.cpu));
                mouseClick(chip(Icons.cpu));
                check(status.open === "", "second click closes the pinned panel");
                console.log("POPOUT_HOVER_PASSED");
            }
        }
    }
}
