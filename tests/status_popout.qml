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

        function selection() {
            const highlight = status.children.find(c => c instanceof Rectangle);
            check(highlight !== undefined, "selection has one moving background");
            return highlight;
        }

        function selectionAt(module) {
            const highlight = selection();
            const position = highlight.mapToItem(module, 0, 0);
            near(position.x, 0, "selection matches the module's x");
            near(position.y, 0, "selection matches the module's y");
            near(highlight.width, module.width, "selection matches the module's width");
            near(highlight.height, module.height, "selection matches the module's height");
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
            const highlight = selection();
            selectionAt(cpu);
            const selectionPosition = () => {
                const point = highlight.mapToItem(null, 0, 0);
                return status.vertical ? point.y : point.x;
            };
            const selectionOrigin = selectionPosition();
            const selectionDistance = status.vertical ? temp.y - cpu.y : temp.x - cpu.x;
            const origin = position(), depth = status.depth;
            const distance = center(temp) - center(cpu);
            status.click("temp", temp);
            check(temp.active && !cpu.active, "selection changes immediately");
            near(selectionPosition(), selectionOrigin, "selection starts at the previous module");
            near(position(), origin, "switch starts at the current box position");
            const samples = [];
            const selectionSamples = [];
            for (let i = 0; i < 4; ++i) {
                wait(100);
                samples.push((position() - origin) / distance);
                selectionSamples.push((selectionPosition() - selectionOrigin) / selectionDistance);
                near(status.depth, depth, "switch moves the open box without folding it");
            }
            check(selectionSamples[0] > 0 && selectionSamples[0] < 0.2, "selection starts gently: " + selectionSamples);
            check(selectionSamples[1] > 0.35 && selectionSamples[1] < 0.65, "selection moves through the gap: " + selectionSamples);
            check(selectionSamples[2] > 0.8 && selectionSamples[2] <= 1, "selection slows near its destination: " + selectionSamples);
            check(samples[0] > 0 && samples[0] < 0.2, "box starts moving gently toward the next module: " + samples);
            check(samples[1] > 0.35 && samples[1] < 0.65, "box travels fastest in the middle: " + samples);
            check(samples[2] > 0.8 && samples[2] <= 1, "box slows near the next module: " + samples);
            wait(40);
            selectionAt(temp);
            near(temp.color.a, 0, "active module lets the moving background show through");
            near(position() - origin, distance, "box follows the distance between modules");
            status.click("cpu", cpu);
            wait(100);
            const interrupted = position();
            const interruptedSelection = selectionPosition();
            const interruptedWidth = highlight.width, interruptedHeight = highlight.height;
            status.click("mem", mem);
            near(selectionPosition(), interruptedSelection, "rapid selection changes keep the current position");
            near(highlight.width, interruptedWidth, "rapid selection changes keep the current width");
            near(highlight.height, interruptedHeight, "rapid selection changes keep the current height");
            near(position(), interrupted, "rapid hover changes keep the current position");
            wait(440);
            selectionAt(mem);
            near(status.offset + status.extent / 2, 8 + center(mem), "box reaches the latest module");
            console.log("POPOUT_HANDOFF_PASSED");
        }

        function test_selection_visibility() {
            configure("right", false, 240);
            const highlight = selection();
            const cpu = chip(Icons.cpu), power = chip(Icons.power);
            near(highlight.opacity, 0, "closed selection is hidden");
            status.click("cpu", cpu);
            selectionAt(cpu);
            near(highlight.opacity, 0, "first selection fades in at its module");
            wait(100);
            check(highlight.opacity > 0 && highlight.opacity < 1, "selection fades in gradually");
            wait(180);
            near(highlight.opacity, 1, "open selection is visible");
            status.close();
            near(highlight.opacity, 1, "closing starts at the current opacity");
            wait(100);
            check(highlight.opacity > 0 && highlight.opacity < 1, "selection fades out gradually");
            const interrupted = highlight.mapToItem(cpu, 0, 0);
            const opacity = highlight.opacity;
            status.click("power", power);
            near(highlight.opacity, opacity, "reopening keeps the current opacity");
            near(highlight.mapToItem(cpu, 0, 0).y, interrupted.y, "reopening keeps the current position");
            wait(280);
            selectionAt(power);
            near(highlight.opacity, 1, "reopened selection is visible");
            status.close();
            wait(280);
            near(highlight.opacity, 0, "closed selection disappears");
            status.click("cpu", cpu);
            selectionAt(cpu);
            console.log("SELECTION_VISIBILITY_PASSED");
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
