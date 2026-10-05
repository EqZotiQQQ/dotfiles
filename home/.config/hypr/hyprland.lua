-- Hyprland Lua config (0.55+; hyprlang .conf is deprecated and removed in 0.57).
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- Lua stubs for LSP autocompletion: /usr/share/hypr/stubs/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "DP-2", mode = "2560x1440@60", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "0x200", scale = 1 })

-- Workspaces 1-9 on DP-2 (primary), 10-18 on DP-1 (secondary); see ~/.local/scripts/ws-switch
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i),     monitor = "DP-2" })
    hl.workspace_rule({ workspace = tostring(i + 9), monitor = "DP-1" })
end


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use (globals: also used in keybindings.lua)
terminal    = "kitty"
fileManager = "dolphin"
menu        = "wofi"


---------------
---- THEME ----
---------------

-- Colors, shapes and motion shared with the Quickshell bar and the lockscreen: ~/.config/theme/theme.json
-- (loaded by theme.lua). If it can't be read, the themed values below fall back to Hyprland's defaults.
-- Hyprland's require() reports a failing module itself and returns a placeholder instead of raising.
local theme_ok, theme = pcall(require, "theme")
if not theme_ok then
    pcall(hl.notification.create, { text = "theme: " .. tostring(theme), timeout = 10000, color = "rgba(ff5555ff)" })
end
if type(theme) ~= "table" or not theme.colors then
    theme = nil
end


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    -- hl.exec_cmd([[sleep 1 && hyprpaper-set "$(find ~/Pictures/wallpapers -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | shuf -n 1)"]])
    hl.exec_cmd("hypridle") -- timeout management, session blocker, sleeper, etc
    -- bar + the spectrum strip behind it (Quickshell: ~/.config/quickshell); edge, size, colors: theme.json
    hl.exec_cmd("qs")
    hl.exec_cmd("mako") -- notification manager
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent") -- password agent for gui apps
    -- hl.exec_cmd(terminal)
    -- hl.exec_cmd("nm-applet")
end)

-- Apps opened at login, each first window sent to its workspace (1-9 DP-2, 10-18 DP-1).
-- Matched by window class, not exec_cmd rules: those track the PID, and code / spotify-launcher
-- open their window from another process.
local startup_apps = {
    { cmd = "spotify-launcher",     class = "Spotify",              workspace = 9 },
    { cmd = "telegram-desktop",     class = "org.telegram.desktop", workspace = 8 },
    { cmd = "code",                 class = "code",                 workspace = 1 },
    { cmd = terminal,               class = "kitty",                workspace = 1 },
    { cmd = "google-chrome-stable", class = "google-chrome",        workspace = 10 },
    { cmd = "obsidian",             class = "md.obsidian.Obsidian", workspace = 11 },
}
local startup_pending = {} -- class -> workspace, until that class's first window appears

local function place_startup_window(w)
    local workspace = w and startup_pending[w.class]
    if not workspace then return end
    startup_pending[w.class] = nil
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace), follow = false, window = "address:" .. w.address }))
end
hl.on("window.open", place_startup_window)

hl.on("hyprland.start", function()
    for _, app in ipairs(startup_apps) do
        startup_pending[app.class] = app.workspace
        hl.exec_cmd(app.cmd)
    end
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Themed look: borders, gaps, rounding, blur (theme.json: colors, shape, blur)
if theme then
    hl.config({
        general = {
            gaps_in     = theme.shape.gapsIn,
            gaps_out    = theme.shape.gapsOut,
            border_size = theme.shape.border,
            col = {
                active_border   = theme.rgba(theme.colors.primary),
                inactive_border = theme.rgba(theme.colors.outlineVariant, 0.67),
            },
        },
        decoration = {
            rounding       = theme.shape.rounding,
            rounding_power = 2,
            blur = {
                size   = theme.blur.size,
                passes = theme.blur.passes,
            },
        },
    })
end

-- Curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

-- Windows move and pop in on the theme's curve (theme.json: motion), with a slight overshoot
local win_curve, win_speed, win_popin = "easeOutQuint", 4.79, "87%"
if theme then
    local c = theme.motion.curve
    hl.curve("fluid", { type = "bezier", points = { { c[1], c[2] }, { c[3], c[4] } } })
    win_curve, win_speed, win_popin = "fluid", theme.motion.hyprSpeed, theme.motion.windowPopin
end

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = win_speed, bezier = win_curve })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = win_speed, bezier = win_curve, style = "popin " .. win_popin })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin " .. win_popin })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
-- hl.config({
--     dwindle = {
--         preserve_split = true, -- You probably want this
--     },
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


require("keybindings")

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Flameshot windowrule
hl.window_rule({
    name  = "flameshot-float",
    match = { class = "flameshot" },

    float          = true,
    move           = { 0, 0 },
    suppress_event = "maximize",
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
