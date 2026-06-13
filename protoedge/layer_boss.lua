local new_Layer = require('protoedge.layer')

---@pkg LayerBoss
local LayerBoss = {}
local _layers = {} ---@type Layer[]
local _order_dirty = false

---@param opts LayerProto?
---@return Layer
function LayerBoss.new_layer(opts)
    local layer = new_Layer(opts)
    table.insert(_layers, layer)
    _order_dirty = true
    return layer
end

function LayerBoss.update()
    if _order_dirty then
        table.sort(_layers, function(a, b)
            return a.id < b.id
        end)
        local div = #_layers - 1
        for i, layer in ipairs(_layers) do
            -- Converts [1, #_layers] to [-1.0, 1.0]
            layer._sort = (i - 1) / div * 2.0 - 1.0
        end
    end
    for _, layer in ipairs(_layers) do
        layer:_do_update()
    end
end

return LayerBoss
