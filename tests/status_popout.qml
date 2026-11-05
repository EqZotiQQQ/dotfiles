import QtQuick
import QtQuick.Shapes
import QtTest
import Quickshell
import qs.bar
import qs.common

ShellRoot {
    Item {
        width: 2000
        height: 2000

        StatusIsland {
            id: status
            x: edge === "left" ? Theme.barMargin : parent.width - Theme.barMargin - width
            y: edge === "top" ? Theme.barMargin : parent.height - Theme.barMargin - height
        }
    }

    TestCase {
        name: "StatusPopout"
        when: true
        onCompletedChanged: if (completed) Qt.quit()

        function check(condition, message) {
            if (!condition) {
                console.error("ASSERTION", message);
                fail(message);
            }
        }

        function near(actual, expected, message) {
            check(Math.abs(actual - expected) < 0.01, message + ": " + actual + " != " + expected);
        }

        function chip(icon) {
            const strip = status.children.find(c => c instanceof Grid);
            return strip.children.find(c => c.icon === icon);
        }

        function configure(edge, flush, duration) {
            status.close();
            wait(Theme.duration + 40);
            Theme.json = {bar: {position: edge, flush: flush}, motion: {durationMs: duration}};
            wait(duration + 40);
        }

        function test_origin_data() {
            const rows = [];
            for (const edge of ["top", "bottom", "left", "right"])
                for (const flush of [true, false])
                    rows.push({tag: edge + "-" + flush, edge: edge, flush: flush});
            return rows;
        }

        function test_origin(data) {
            configure(data.edge, data.flush, 120);
            for (const entry of [["cpu", Icons.cpu], ["temp", Icons.thermometer], ["mem", Icons.memory], ["power", Icons.power]]) {
                const module = chip(entry[1]);
                check(module !== undefined, "module exists: " + entry[0]);
                const start = 8 + (status.vertical ? module.y : module.x);
                const size = status.vertical ? module.height : module.width;
                const fixed = module.mapToItem(null, 0, 0);
                status.click(entry[0], module);
                near(status.offset, start, "opening starts at the module's leading edge");
                near(status.end, start + size, "opening starts at the module's trailing edge");
                near(status.depth, 0, "opening starts folded");
                const outline = status.children.find(c => c instanceof Shape).data[0];
                const path = outline.pathElements;
                const along = point => status.vertical ? point.y : point.x;
                check(along(path[10]) >= along(path[9]) - 0.01, "rounded end does not fold back over itself");
                wait(160);
                near(status.depth, status.vertical ? status.contentWidth : status.contentHeight, "full depth");
                near(status.extent, status.vertical ? status.contentHeight : status.contentWidth, "full extent");
                const expanded = module.mapToItem(null, 0, 0);
                near(expanded.x, fixed.x, "opening keeps the module's screen x");
                near(expanded.y, fixed.y, "opening keeps the module's screen y");
                status.close();
                check(status.depth > 0, "closing keeps the panel for the animation");
                wait(160);
                near(status.depth, 0, "closed depth");
                near(status.offset, start, "closing returns to the module's leading edge");
                near(status.end, start + size, "closing returns to the module's trailing edge");
                check(status.panel.children[0].item === null, "content unloads after closing");
            }
            console.log("POPOUT_ORIGIN_PASSED");
        }

        function test_easing() {
            configure("top", true, 800);
            status.click("cpu", chip(Icons.cpu));
            const opening = [0];
            for (let i = 0; i < 4; ++i) {
                wait(200);
                opening.push(status.depth / status.contentHeight);
            }
            check(opening[1] < 0.2, "opening accelerates gently: " + opening);
            check(opening[2] > 0.35 && opening[2] < 0.65, "opening is halfway at midpoint: " + opening);
            check(opening[3] > 0.8 && opening[3] <= 1, "opening slows near the end: " + opening);
            wait(40);
            status.close();
            const closing = [];
            for (let i = 0; i < 4; ++i) {
                wait(200);
                closing.push(status.depth / status.contentHeight);
            }
            check(closing[0] > 0.8 && closing[0] <= 1, "closing starts gently: " + closing);
            check(closing[1] > 0.35 && closing[1] < 0.65, "closing is halfway at midpoint: " + closing);
            check(closing[2] >= 0 && closing[2] < 0.2, "closing slows near the end: " + closing);
            console.log("POPOUT_EASING_PASSED");
        }

        function test_handoff_data() {
            return ["top", "bottom", "left", "right"].map(edge => ({tag: edge, edge: edge}));
        }

        function test_handoff(data) {
            configure(data.edge, false, 400);
            const cpu = chip(Icons.cpu), temp = chip(Icons.thermometer), mem = chip(Icons.memory);
            const center = module => status.vertical ? module.y + module.height / 2 : module.x + module.width / 2;
            const position = () => {
                const point = status.panel.mapToItem(null, 0, 0);
                return status.vertical ? point.y : point.x;
            };
            status.click("cpu", cpu);
            wait(440);
            const origin = position(), depth = status.depth;
            const distance = center(temp) - center(cpu);
            status.click("temp", temp);
            near(position(), origin, "switch starts at the current box position");
            const samples = [];
            for (let i = 0; i < 4; ++i) {
                wait(100);
                samples.push((position() - origin) / distance);
                near(status.depth, depth, "switch moves the open box without folding it");
            }
            check(samples[0] > 0 && samples[0] < 0.2, "box starts moving gently toward the next module: " + samples);
            check(samples[1] > 0.35 && samples[1] < 0.65, "box travels fastest in the middle: " + samples);
            check(samples[2] > 0.8 && samples[2] <= 1, "box slows near the next module: " + samples);
            wait(40);
            near(position() - origin, distance, "box follows the distance between modules");
            status.click("cpu", cpu);
            wait(100);
            const interrupted = position();
            status.click("mem", mem);
            near(position(), interrupted, "rapid hover changes keep the current position");
            wait(440);
            near(status.offset + status.extent / 2, 8 + center(mem), "box reaches the latest module");
            console.log("POPOUT_HANDOFF_PASSED");
        }

        function test_screen_boundary() {
            configure("top", false, 120);
            const strip = status.children.find(c => c instanceof Grid);
            const first = strip.children.find(c => c.visible && typeof c.icon === "string");
            status.parent.width = status.length + 60;
            status.click("cpu", first);
            wait(160);
            near(status.panel.mapToItem(null, 0, 0).x, Theme.barMargin, "box stays within the screen margin");
            status.parent.width = 2000;
            wait(160);
            near(status.offset + status.extent / 2, 8 + first.x + first.width / 2, "box centers on its module when there is room");
            console.log("POPOUT_SCREEN_BOUNDARY_PASSED");
        }

        function test_interruption() {
            configure("right", false, 240);
            status.click("cpu", chip(Icons.cpu));
            wait(100);
            const depth = status.depth, offset = status.offset, end = status.end;
            status.close();
            near(status.depth, depth, "closing mid-opening does not jump");
            near(status.offset, offset, "leading edge stays continuous on close");
            near(status.end, end, "trailing edge stays continuous on close");
            wait(60);
            const closingDepth = status.depth, closingOffset = status.offset, closingEnd = status.end;
            status.click("mem", chip(Icons.memory));
            near(status.depth, closingDepth, "reopening mid-close does not jump");
            near(status.offset, closingOffset, "leading edge stays continuous on reopen");
            near(status.end, closingEnd, "trailing edge stays continuous on reopen");
            wait(280);
            const oldExtent = status.extent;
            status.panel.children[0].item.implicitHeight = 900;
            near(status.extent, oldExtent, "new content size does not jump");
            wait(280);
            near(status.extent, 936, "tall content reaches its full size");
            check(status.offset < 0, "tall content extends past the island start");
            const oldOffset = status.offset;
            status.click("temp", chip(Icons.thermometer));
            near(status.offset, oldOffset, "switching an open panel does not jump");
            wait(280);
            near(status.extent, 276, "switching returns to the new content size");
            status.close();
            wait(280);
            console.log("POPOUT_INTERRUPTION_PASSED");
        }
    }
}
