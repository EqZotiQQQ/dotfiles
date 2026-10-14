-- Monitors in a fixed order and the workspaces each one owns: the n-th monitor gets ids 9(n-1)+1 .. 9n,
-- shown as 1..9 on its bar. Order: the largest first (the main screen), then left to right, top to bottom.
-- Read from Hyprland on every call, so any set of monitors works; hyprland.lua reloads the config when
-- one is plugged in or out, to rebuild its workspace rules.
local M = {}

M.per_monitor = 9

function M.list()
    local mons = {}
    for _, m in ipairs(hl.get_monitors()) do
        -- FALLBACK: Hyprland's placeholder while no monitor is connected (one that drops off when the screen
        -- sleeps); given workspaces 1-9, it leaves the returning monitor on 11
        if not m.is_mirror and m.name ~= "FALLBACK" then table.insert(mons, m) end
    end
    table.sort(mons, function(a, b)
        local area_a, area_b = a.width * a.height, b.width * b.height
        if area_a ~= area_b then return area_a > area_b end
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    return mons
end

-- Workspace id of key n (1..9) on the slot-th monitor (1 = main); no such monitor -> the main one
function M.workspace(slot, n)
    if slot > #M.list() then slot = 1 end
    return (slot - 1) * M.per_monitor + n
end

-- Workspace id of key n on the focused monitor
function M.focused_workspace(n)
    local active = hl.get_active_monitor()
    for slot, m in ipairs(M.list()) do
        if active and m.name == active.name then return M.workspace(slot, n) end
    end
    return n
end

return M
