
local naughty = require("naughty")
local awesome = _G.awesome


local errors = {}

errors.startup_error_check = function()
    if awesome.startup_errors then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors
        })
    end
end

return errors