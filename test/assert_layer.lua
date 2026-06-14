local assert = require('test.assert')

local assert_layer = {}

---@param layer Layer
---@param tiles integer[]
function assert_layer.tiles(layer, tiles)
    assert.same(tiles, layer._tile)
end

return assert_layer
