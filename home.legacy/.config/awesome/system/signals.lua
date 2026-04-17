local signals = {}

function signals.connect_signal(name, callback)
    signals[name] = signals[name] or {}
    table.insert(signals[name], callback)
end

function signals.disconnect_signal(name, callback)
    signals[name] = signals[name] or {}

    for k, v in ipairs(signals[name]) do
        if v == callback then
            table.remove(signals[name], k)
            break
        end
    end
end

function signals.emit_signal(name, ...)
    signals[name] = signals[name] or {}

    for _, cb in ipairs(signals[name]) do
        cb(...)
    end
end

return signals
