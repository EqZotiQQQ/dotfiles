---------------------------------------------------------------------------
--- Audio control
--
-- @module system.audio
---------------------------------------------------------------------------

local d = require("dbg")
local awful = require("awful")
local posix_signal = require("posix.signal")
local naughty = require("naughty")
local gears = require("gears")
local util = require("common.util")
local posix = require("posix")
local cava_config = require("configs.cava")

local tonumber = tonumber
local tostring = tostring
local bit = util.bit

d.n("audio module")

local audio = {
    volume = {},
    mute = {},
    sink = 0,
    on_event = {},
    cava = {
        max_value = 65536,
        raw_val = {},
        read_buf = "",
        fifo = nil,
    },
    player = {}
}

local signals = {}

function audio.init_pulse_subscription()
    d.n("audio.init_pulse_subscription()")
    audio.subscription_pid = awful.spawn.with_line_callback(
        "pactl subscribe",
        {
            stdout = function(line)
                local event, object, id = line:match([[Event '(%a+)' on ([a-z\-]+) #(%d)]])
                local object = object:gsub('-', '_')
                local id = tonumber(id)
                if audio.on_event[object] ~= nil and audio.on_event[object][event] ~= nil then
                    audio.on_event[object][event](id)
                end
            end,
            stderr = function(line)
                -- TODO: Reconnect on error?
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Audio",
                    text = line,
                })
            end
        }
    )
end

-- Event actions
audio.on_event.sink = {}
audio.on_event.sink_input = {}

function audio.on_event.sink.change(id)
    d.n("audio.on_event.sink.change("..id..")")
    if id ~= nil then
        audio:sink_status_update()
    end
end

function audio.on_event.sink.remove(id)
    d.n("audio.on_event.sink.remove("..id..")")
    if id == audio.sink then
        audio:init_default_sink()
    end
end

function audio.on_event.sink.new(id)
    d.n("audio.on_event.sink.new("..id..")")
    if id == audio.sink then
        audio:init_default_sink()
    end
end

function audio.on_event.sink_input.change(_)
    d.n("audio.on_event.sink.change()")
    audio:init_default_sink()
end

audio.cava.config_template = [[
[general]
framerate = <framerate>
autosens = 1
bars = <bars>
lower_cutoff_freq = 50
higher_cutoff_freq = 10000
[output]
method = raw
channels = stereo
raw_target = /tmp/cava
data_format = binary
ascii_max_range = 1000
bit_format = 16bit
[smoothing]
integral = 30
monstercat = 1
waves = 0
gravity = 100
[eq]
1 = 1
2 = 1
3 = 1
4 = 1
5 = 1
]]

function audio.cava:init()
    d.n("audio.sink.init()")
    if self.initialized then return end

    self.config = {
        update_time = cava_config.update_time,
        bars = cava_config.bars,
    }

    local cava_config = self.config_template
        :gsub("<framerate>", 1 / self.config.update_time)
        :gsub("<bars>", self.config.bars)
    util.file.new("/tmp/cava_config", cava_config)
    self.pid = awful.spawn("cava -p /tmp/cava_config")
    self.update_timer = gears.timer.start_new(
        self.config.update_time,
        function()
            local success, msg = pcall(self.parse_fifo, self)
            if success then
                self:update()
            end
            return true -- Ignore errors
        end
    )

    self.initialized = true
end

function audio.cava:parse_fifo()
    -- d.n("audio.sink.parse_fifo()")
    local errmsg
    if not self.fifo then
        -- Closed in destructor
        self.fifo, errmsg = posix.open("/tmp/cava", posix.O_RDONLY + posix.O_NONBLOCK)
    end

    if not self.fifo then return false, errmsg end

    local bufsize = self.config.bars * 2

    local cava_data, errmsg = posix.read(self.fifo, bufsize)
    if not cava_data then return false, errmsg end

    self.read_buf = self.read_buf..cava_data
    while #self.read_buf / 2 >= self.config.bars do
        self.raw_val = {}
        for byte = 1, self.config.bars do
            local high_byte = util.read_high_byte(self.read_buf:byte(byte * 2))
            -- local high_byte = self.read_buf:byte(byte * 2) << 8
            local low_byte = self.read_buf:byte(byte * 2 - 1)
            table.insert(self.raw_val, high_byte + low_byte)
        end

        self.read_buf = self.read_buf:sub(bufsize + 1)

        -- Extra read attempt in case of accumulated data
        cava_data = posix.read(self.fifo, bufsize)
        if not cava_data then return true, self.raw_val end

        self.read_buf = self.read_buf..cava_data
    end

    return true, self.raw_val
end

function audio.cava:update()
    audio.emit_signal("cava::updated")
end

function audio:init_default_sink()
    d.n("audio.sink.init_default_sink()")
    awful.spawn.easy_async("pactl list sinks short",
        function(out)
            local old_sink = self.sink
            self.sink = tonumber(out:match("(%d+)%s+[^\n]-%s+RUNNING\n") or out:match("(%d+)%s+[^\n]-%s+IDLE\n"))
            if old_sink ~= self.sink then
                self.emit_signal("audio::volume")
            end
        end
    )
end

function audio:sink_status_update()
    d.n("audio.sink.sink_status_update()")
    awful.spawn.easy_async(
        "pactl list sinks",
        function(out)
            for sink, mute, vol in out:gmatch(
                    "Sink #(%d+).-"..
                    "\n%s+Mute:%s*(%a+).-"..
                    "\n%s+Volume:[^\n]-(%d+)%%[^\n]-\n"
                ) do
                local sink = tonumber(sink)
                local vol = tonumber(vol)
                local mute = mute == "yes"
                if self.volume[sink] ~= vol then
                    self.volume[sink] = vol
                    self.emit_signal("audio::volume")
                end

                -- d.notify(mute)
                -- if self.mute[sink] ~= mute then
                --     self.emit_signal("audio::mute")
                --     self.mute[sink] = mute
                -- else
                --     self.emit_signal("audio::unmute")
                --     self.mute[sink] = mute
                -- end
            end
        end
    )
end

--- Get audio volume method
-- @tparam[opt=default] number sink Sink number
-- @treturn number volume level in percentage
function audio:volume_get(sink)
    d.n("audio:volume_get("..sink..")")
    local sink = sink or self.sink
    if sink ~= nil then
        return self.volume[sink]
    else
        return 0
    end
end

--- Set audio volume method
-- @tparam number volume Volume level in percentage
-- @tparam[opt=default] number sink Sink number
function audio:volume_set(volume, sink)
    d.n("audio:volume_set()")
    local sink = sink or self.sink
    if sink ~= nil then
        awful.spawn("pactl set-sink-volume "..sink.." "..volume)
    end
end

function audio:volume_mute_impl(stdout)
    d.n("audio:volume_mute_impl(...)")
    local is_mute = stdout:sub(7, 7)
    if is_mute == "y" then
        self.emit_signal("audio::unmute")
    else
        self.emit_signal("audio::mute")
    end
end

--- Mute audio method
-- @tparam[opt="toggle"] string val "toggle", "true" or "false"
-- @tparam[opt=default] number sink Sink number
function audio:volume_mute(val, sink)
    d.n("audio:volume_mute("..val..", "..sink..")")
    local sink = sink or self.sink
    local val = val and tostring(val) or "toggle"
    if sink ~= nil then
        local get_cmd = "pactl get-sink-mute "..sink
        local a = awful.spawn.easy_async(get_cmd,
            function(stdout)
                audio:volume_mute_impl(stdout)
            end)
        local cmd = "pactl set-sink-mute "..sink.." "..val
        awful.spawn(cmd)
    end
end

--- Subscribe to audio events. Following events are available:
-- * "cava::updated"
-- * "audio::volume"
-- * "audio::mute"
--
-- @tparam string name Event name
-- @tparam function callback Callback function
function audio.connect_signal(name, callback)
    d.n("audio.connect_signal(...)")
    signals[name] = signals[name] or {}
    table.insert(signals[name], callback)
end

--- Unsubscribe from audio events. Same function pointer has to be provided to unsubscribe.
-- @tparam string name Event name
-- @tparam function callback Callback function
function audio.disconnect_signal(name, callback)
    d.n("audio.disconnect_signal(...)")
    signals[name] = signals[name] or {}

    for k, v in ipairs(signals[name]) do
        if v == callback then
            table.remove(signals[name], k)
            break
        end
    end
end

function audio.emit_signal(name, ...)
    -- d.n("audio.emit_signal(...)")
    signals[name] = signals[name] or {}

    for _, cb in ipairs(signals[name]) do
        cb(...)
    end
end

audio.mt = {}

function audio.mt:__gc()
    d.n("audio.mt:__gc()")
    posix_signal.kill(audio.subscription_pid)
    posix_signal.kill(audio.cava.pid)
    if audio.cava.fifo then
        posix.close(audio.cava.fifo)
    end

end

audio:init_pulse_subscription()
audio:init_default_sink()
audio:sink_status_update()
audio.cava:init()

if _G._VERSION == "Lua 5.1" then
    -- Lua 5.1 and LuaJIT without Lua5.2 compat does not support __gc on tables, so we need to use newproxy
    local g = newproxy(false)
    debug.setmetatable(g, {__gc = audio.mt.__gc})
    audio._garbage = g
end

return setmetatable(audio, audio.mt)
