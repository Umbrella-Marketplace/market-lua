local Placeholder = {}

function Placeholder.Replace(template, values)
    return (template:gsub("{(.-)}", function(key)
        return tostring(values[key] or ("{" .. key .. "}"))
    end))
end

return Placeholder