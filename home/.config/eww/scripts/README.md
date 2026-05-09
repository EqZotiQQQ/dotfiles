# eww scripts

Scripts polled or event-driven by eww widgets. All scripts are executable shell files.

## Data scripts

### `active-window`
Outputs the title of the focused window, with class-specific icons (firefox → , kitty → ).
After the initial output it streams updates via Hyprland's socket2, reacting to `activewindow`, `openwindow`, and `closewindow` events. Designed to run as a long-lived `eww listen` source.

**Dependencies:** `hyprctl`, `socat`, `jq`

---

### `workspaces`
Outputs a JSON array of 5 workspace objects:
```json
[{"id":1,"active":true,"occupied":false}, ...]
```
After the initial snapshot it streams updates on workspace and window events via socket2.

**Dependencies:** `hyprctl`, `socat`, `jq`

---

### `cpu`
Outputs overall CPU usage as a single integer (0–100). Reads `/proc/stat` twice with a 0.3s sleep between samples to compute a delta.

**Output:** `42`

---

### `cpu-cores`
Outputs per-core usage and top-5 CPU processes as JSON. Uses a cache in `/tmp/eww_cpu_cores/` to compute deltas between polls (no sleep, instant).

**Output:**
```json
{"cores":[{"id":0,"pct":12}, ...],"procs":[{"name":"firefox","pct":"3.2"}, ...]}
```

---

### `memory-details`
Reads `/proc/meminfo` and `ps aux` to output RAM/cache/swap stats and top-5 memory-hungry processes.

**Output:**
```json
{
  "total": "16.0G", "used": "8.1G", "cached": "3.2G",
  "swap_used": "0M", "swap_total": "8.0G",
  "used_pct": 50, "cache_pct": 20, "swap_pct": 0,
  "has_swap": true,
  "procs": [{"name":"firefox","pct":5,"mem":"820M"}, ...]
}
```

---

### `temperatures`
Reads all `hwmon` thermal sensors from `/sys/class/hwmon/` and outputs a JSON array.

**Output:**
```json
[{"device":"k10temp","label":"Tccd1","temp":45}, ...]
```
Skips sensors that report 0°C.

---

### `network`
Outputs a one-line string with the active interface, signal strength (Wi-Fi) or interface name (Ethernet), and current RX/TX speeds. Speeds are computed from deltas cached in `/tmp/eww_network_cache`.

**Output (Wi-Fi):** `󰤨  82%  ↓1.2M ↑120K`
**Output (Ethernet):** `󰈀  eth0  ↓450K ↑80K`

**Dependencies:** `ip`, `iw` (Wi-Fi only)

---

### `volume`
Reads/controls the default PipeWire sink via `wpctl`.

**Usage:**
```bash
volume          # print current volume icon + percentage
volume up       # +5%, flash animation via eww update
volume down     # -5%, flash animation
volume mute     # toggle mute
```

**Output:** `󰖀  58%` or `󰝟  muted`

---

### `audio-sinks`
Lists all PulseAudio/PipeWire sinks with their name, description, and whether they are the current default. Output is a JSON array.

**Output:**
```json
[{"name":"alsa_output.pci...","desc":"Built-in Audio","active":true}, ...]
```

---

### `audio-sink-select`
Sets the given sink as the default, refreshes the `audio-sinks` eww variable, and closes the sink popup on both monitors.

**Usage:** `audio-sink-select <sink-name>`

---

## Popup management scripts

All popup windows follow the naming convention `<prefix>-0` (monitor 0) and `<prefix>-1` (monitor 1).

### `popup-open <window-prefix> <pin-var>`
Opens the popup on the currently focused monitor. Starts a background `popup-auto-close` timer, cancelling any previous timer for the same prefix.

### `popup-toggle <window-prefix> <pin-var>`
Toggles the pin variable. When unpinning, closes both monitor windows immediately.

### `popup-hover-out <window-prefix> <pin-var>`
Closes both monitor windows unless the popup is pinned (`pin-var == "true"`). Called on mouse-leave events.

### `popup-auto-close <window-prefix> <pin-var>`
Waits 5 seconds, then closes both monitor windows if the popup is not pinned. Launched as a background process by `popup-open`.

---

## Adding a new script

1. Create the script in this directory and make it executable (`chmod +x`).
2. Symlink it: `ln -s ~/.config/eww/scripts/<name> <name>` (symlink manager skips this dir).
3. Reference it from `eww.yuck` via `:script` or `run-while`.
4. **Update both this README and the `eww (статусбар) → Скрипты` section in `CLAUDE.md`** to document the new script.
