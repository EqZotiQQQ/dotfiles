local utils = { file = {}, string = {}, table = {} }

function utils.file.exists(path)
    local handle = io.open(path)
    if handle then
        handle:close()
    end
    return handle and true or false
end

function utils.file.read(path)
    local handle = io.open(path, "r")
    if not handle then
        return nil
    end
    local text = handle:read('*all')
    handle:close()
    return text
end

function utils.file.new(path, content)
    local handle = io.open(path, "w")
    if not handle then
        return nil
    end
    if content ~= nil then
        handle:write(content)
    end
    handle:close()
end

function utils.string.trim(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function utils.table.size(table)
    local count = 0
    for _, v in pairs(table) do
        if v ~= nil then
            count = count + 1
        end
    end

    return count
end

return utils
