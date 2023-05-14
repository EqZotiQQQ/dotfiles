------------------------------
-- This is the audio widget --
------------------------------
local d = require("dbg")
-- Awesome Libs
local awful = require("awful")
local color = require("theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/icons/kblayout/"

local font = {
  regular = "JetBrainsMono Nerd Font, 14",
  bold = "JetBrainsMono Nerd Font, bold 14",
  extrabold = "JetBrainsMono Nerd Font, ExtraBold 14",
  specify = "JetBrainsMono Nerd Font"
}
-- local kblayout = { "en", "ru" }
local kblayout = { "ru", "us" }

return function(s)
  local kblayout_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              resize = false,
              image = gears.color.recolor_image(icondir .. "keyboard.svg", color["Grey900"])
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "kblayout_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = color["Green200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  local function get_kblayout()
    awful.spawn.easy_async_with_shell(
      [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
      function(stdout)
        -- d.p("get_kblayout "..stdout)
        local layout = stdout:gsub("\n", "")
        kblayout_widget.container.kblayout_layout.label.text = layout
        awesome.emit_signal("update::background:kblayout")
      end
    )
  end

  local function create_kb_layout_item(keymap)
    local longname, shortname

    local xkeyboard_country_code = {
      { "us", "English (Bri'ish)", "ENG" }, -- United Kingdom
      { "ru", "Русский (Russia)", "RUS" }, -- Russia
    }

    for _, c in ipairs(xkeyboard_country_code) do
      if c[1] == keymap then
        longname = c[2]
        shortname = c[3]
      end
    end

    local kb_layout_item = wibox.widget {
      {
        {
          {
            {
              text = shortname,
              widget = wibox.widget.textbox,
              font = font.extrabold,
              id = "shortname"
            },
            fg = color["Red200"],
            widget = wibox.container.background,
            id = "background2"
          },
          {
            {
              text = longname,
              widget = wibox.widget.textbox,
              font = font.bold,
              id = "longname",
            },
            fg = color["Purple200"],
            widget = wibox.container.background,
            id = "background1"
          },
          spacing = dpi(15),
          layout = wibox.layout.fixed.horizontal,
          id = "container"
        },
        margins = dpi(10),
        widget = wibox.container.margin,
        id = "margin"
      },
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
      end,
      bg = color["Grey800"],
      fg = color["White"],
      widget = wibox.container.background,
      id = "background",
      keymap = keymap
    }

    -- TODO: Hover effects, this is more pain than I'm willing to take for now
    awesome.connect_signal(
      "update::background:kblayout",
      function()
        awful.spawn.easy_async_with_shell(
          [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
          function(stdout)
            -- d.p("update::background:kblayout "..stdout)
            local layout = stdout:gsub("\n", "")
            -- d.p("update::background:kblayout -> "..stdout)
            if kb_layout_item.keymap == layout then
              kb_layout_item.bg = color["DeepPurple200"]
              kb_layout_item:get_children_by_id("background2")[1].fg = color["Grey900"]
              kb_layout_item:get_children_by_id("background1")[1].fg = color["Grey900"]
            else
              kb_layout_item.bg = color["Grey800"]
              kb_layout_item:get_children_by_id("background2")[1].fg = color["Red200"]
              kb_layout_item:get_children_by_id("background1")[1].fg = color["Purple200"]
            end
          end
        )
      end
    )

    get_kblayout()

    kb_layout_item:connect_signal(
      "button::press",
      function()
        -- d.p("button::press -> kb_layout_item")
        awful.spawn.easy_async_with_shell(
          "setxkbmap " .. keymap,
          function()
            -- d.p("setxkbmap "..keymap)
            awesome.emit_signal("kblayout::hide:kbmenu")
            mousegrabber.stop()
            get_kblayout()
          end
        )
      end
    )
    return kb_layout_item
  end

  local function get_kblist()
    local kb_layout_items = {
      layout = wibox.layout.fixed.vertical,
      spacing = dpi(10)
    }
    for i, keymap in pairs(kblayout) do
      kb_layout_items[i] = create_kb_layout_item(keymap)
      -- d.n(i.." "..keymap)
    end
    local cont = {
      {
        kb_layout_items,
        margins = dpi(10),
        widget = wibox.container.margin
      },
      layout = wibox.layout.fixed.vertical,
    }
    return cont
  end

  local kb_menu_widget = awful.popup {
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 12)
    end,
    widget = wibox.container.background,
    bg = color["Grey900"],
    fg = color["White"],
    border_width = dpi(4),
    border_color = color["Grey800"],
    width = dpi(100),
    max_height = dpi(600),
    visible = false,
    ontop = true,
    placement = function(c)
      awful.placement.align(
        c,
        {
          position = "top_right",
          margins = {
            right = dpi(255),
            top = dpi(60)
          }
        }
      )
    end
  }

  kb_menu_widget:connect_signal(
    "mouse::leave",
    function()
      mousegrabber.run(
        function()
          kblayout_widget.bg = color["Green200"]
          awesome.emit_signal("kblayout::hide:kbmenu")
          mousegrabber.stop()
          return true
        end,
        "arrow"
      )
    end
  )

  kb_menu_widget:connect_signal(
    "mouse::enter",
    function()
      mousegrabber.stop()
    end
  )

  kb_menu_widget:setup(
    get_kblist()
  )

  local function toggle_kb_layout()
    awful.spawn.easy_async_with_shell(
      "setxkbmap -query | grep layout: | awk '{print $2}'",
      function(stdout)
        for j, n in ipairs(kblayout) do
          if stdout:match(n) then
            if j == #kblayout then
              awful.spawn.easy_async_with_shell(
                "setxkbmap " .. kblayout[1],
                function()
                  get_kblayout()
                end
              )
            else
              awful.spawn.easy_async_with_shell(
                "setxkbmap " .. kblayout[j + 1],
                function()
                  get_kblayout()
                end
              )
            end
          end
        end
      end
    )
  end

  awesome.connect_signal(
    "kblayout::toggle",
    function()
      -- d.n("kblayout::toggle")
      toggle_kb_layout()
    end
  )

  -- Signals
  Hover_signal(kblayout_widget, color["Green200"], color["Grey900"])

  local kblayout_keygrabber = awful.keygrabber {
    autostart = false,
    stop_event = 'release',
    keypressed_callback = function(self, mod, key, command)
      awesome.emit_signal("kblayout::hide:kbmenu")
      mousegrabber.stop()
    end
  }

  kblayout_widget:connect_signal(
    "button::press",
    function()
      mousegrabber.stop()
      if kb_menu_widget.visible then
        kb_menu_widget.visible = false
        kblayout_keygrabber:stop()
      else
        kb_menu_widget.visible = true
        kblayout_keygrabber:start()
      end
    end
  )

  awesome.connect_signal(
    "kblayout::hide:kbmenu",
    function()
      -- d.n("kblayout::hide:kbmenu")
      kb_menu_widget.visible = false
      kblayout_keygrabber:stop()
    end
  )

  get_kblayout()
  kb_menu_widget.visible = false
  return kblayout_widget
end
