local beautiful = require("beautiful")

local calendar_themes = {
    nord = {
        bg = '#2E3440',
        fg = '#D8DEE9',
        focus_date_bg = '#88C0D0',
        focus_date_fg = '#000000',
        weekend_day_bg = '#3B4252',
        weekday_fg = '#88C0D0',
        header_fg = '#E5E9F0',
        border = '#4C566A'
    },
    outrun = {
        bg = '#0d0221',
        fg = '#D8DEE9',
        focus_date_bg = '#650d89',
        focus_date_fg = '#2de6e2',
        weekend_day_bg = '#261447',
        weekday_fg = '#2de6e2',
        header_fg = '#f6019d',
        border = '#261447'
    },
    dark = {
        bg = '#000000',
        fg = '#ffffff',
        focus_date_bg = '#ffffff',
        focus_date_fg = '#000000',
        weekend_day_bg = '#444444',
        weekday_fg = '#ffffff',
        header_fg = '#ffffff',
        border = '#333333'
    },
    light = {
        bg = '#ffffff',
        fg = '#000000',
        focus_date_bg = '#000000',
        focus_date_fg = '#ffffff',
        weekend_day_bg = '#AAAAAA',
        weekday_fg = '#000000',
        header_fg = '#000000',
        border = '#CCCCCC'
    },
    monokai = {
        bg = '#272822',
        fg = '#F8F8F2',
        focus_date_bg = '#AE81FF',
        focus_date_fg = '#ffffff',
        weekend_day_bg = '#75715E',
        weekday_fg = '#FD971F',
        header_fg = '#F92672',
        border = '#75715E'
    },
    naughty = {
        bg = beautiful.notification_bg or beautiful.bg,
        fg = beautiful.notification_fg or beautiful.fg,
        focus_date_bg = beautiful.notification_fg or beautiful.fg,
        focus_date_fg = beautiful.notification_bg or beautiful.bg,
        weekend_day_bg = beautiful.bg_focus,
        weekday_fg = beautiful.fg,
        header_fg = beautiful.fg,
        border = beautiful.border_normal
    }
}

return calendar_themes