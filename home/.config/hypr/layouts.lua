-- Layout per workspace, switched through a list like AwesomeWM's awful.layout.inc (keys: keybindings.lua;
-- the icon: quickshell bar/LayoutBox.qml). A choice is set as the workspace's rule (layout + layout_opts):
-- Hyprland merges it into the rule hyprland.lua made for that workspace and re-tiles it at once.
-- Choices are kept in $XDG_RUNTIME_DIR/hypr-layouts.json, which the bar reads too: a config reload (a monitor
-- plugged in or out) starts Lua afresh, and restore() puts them back. The file is gone after logout.
local json = require("lib.json")

local M = {}

-- name: the bar draws an icon per name. The first one is what a workspace starts with: keep it general.layout
-- in hyprland.lua. awesome's names: tile has the stack right of the master, tile.left left of it, and so on.
M.list = {
    { name = "dwindle",     layout = "dwindle" },
    { name = "tile",        layout = "master", opts = { orientation = "left" } },
    { name = "tile.left",   layout = "master", opts = { orientation = "right" } },
    { name = "tile.bottom", layout = "master", opts = { orientation = "top" } },
    { name = "tile.top",    layout = "master", opts = { orientation = "bottom" } },
    { name = "scrolling",   layout = "scrolling" },
}

local path   = os.getenv("XDG_RUNTIME_DIR") .. "/hypr-layouts.json"
local chosen = {} -- workspace id (string) -> layout name

local function find(name)
    for i, entry in ipairs(M.list) do
        if entry.name == name then return i end
    end
end

local function apply(id, entry)
    hl.workspace_rule({ workspace = id, layout = entry.layout, layout_opts = entry.opts })
end

local function save()
    local f = io.open(path, "w")
    if not f then return end
    f:write(json.encode({ default = M.list[1].name, workspaces = chosen }))
    f:close()
end

-- Put the kept choices back (hyprland.lua, on every config load). A broken file only loses them:
-- an error here would stop the rest of the config from loading
function M.restore()
    local f = io.open(path, "r")
    if f then
        local ok, state = pcall(json.decode, f:read("a"))
        f:close()
        if ok and type(state) == "table" and type(state.workspaces) == "table" then chosen = state.workspaces end
    end
    for id, name in pairs(chosen) do
        local i = find(name)
        if i then apply(id, M.list[i]) else chosen[id] = nil end
    end
    save()
end

-- Next (step 1) or previous (-1) layout of workspace id; no id -> the one on the focused monitor
function M.cycle(step, id)
    if not id then
        local ws = hl.get_active_workspace()
        if not ws then return end
        id = ws.id
    end
    id = tostring(id)
    local i = find(chosen[id]) or 1
    local entry = M.list[(i - 1 + step) % #M.list + 1]
    chosen[id] = entry.name
    apply(id, entry)
    save()
end

return M
