
local naughty = require("naughty")
local awesome = _G.awesome
local client_signals = require("signals.client_signals")


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

errors.add_runtime_error_check_signal = function()
    do
        local in_error = false
        awesome.connect_signal(
            client_signals.debug.error,
            function (err)
                -- Make sure we don't go into an endless error loop
                if in_error then
                    return
                end
                in_error = true

                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err)
                })
                in_error = false
            end
        )
    end
end

return errors