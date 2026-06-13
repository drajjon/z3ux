local new_Layer = require('protoedge.layer')

---@class LayerBoss
local LayerBoss = {}
local _layers = {} ---@type Layer[]

---@param opts LayerProto?
---@return Layer
function LayerBoss.new_layer(opts)
    local layer = new_Layer(opts)
    table.insert(_layers, layer)
    return layer
end

function LayerBoss.update()
    -- TODO: sort layers
    -- TODO: assign Z range to Layer._sort
    for _, layer in ipairs(_layers) do
        layer:update()
    end
end

return LayerBoss
