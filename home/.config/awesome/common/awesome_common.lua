-- Awesome stack
local awesome = _G.awesome

local awesome_common = {}

awesome_common.restart = function()
    awesome.restart()
end

awesome_common.quit = function()
    awesome.quit()
end

return awesome_common