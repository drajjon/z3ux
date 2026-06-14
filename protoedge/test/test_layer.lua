-----------------------------------------------------------------------------------------
--
-- Tests: Layer
--
-----------------------------------------------------------------------------------------

local new_Layer = require('protoedge.layer')
local assert = require('test.assert')
local assert_layer = require('test.assert_layer')

return function()
    context('Layer', function()
        before(function()
        end)

        after(function()
        end)

        test('basic Layer test', function()
            local layer = new_Layer { width = 2, height = 2 }
            layer:poke(1, 1, 101)
            layer:poke(2, 1, 202)
            layer:poke(1, 2, 303)
            layer:poke(2, 2, 404)
            assert_layer.tiles(layer, { 101, 202, 303, 404 })
        end)

        test('hollow rectangle', function()
            local layer = new_Layer { width = 4, height = 4 }
            layer:rect({ x = 1, y = 1, w = 3, h = 3 }, { tile = 5 }, true)
            assert_layer.tiles(layer, {
                5, 5, 5, nil,
                5, nil, 5, nil,
                5, 5, 5
            })
        end)

        test('filled rectangle', function()
            local layer = new_Layer { width = 4, height = 4 }
            layer:rect({ x = 2, y = 1, w = 3, h = 4 }, { tile = 5 })
            assert_layer.tiles(layer, {
                nil, 5, 5, 5,
                nil, 5, 5, 5,
                nil, 5, 5, 5,
                nil, 5, 5, 5
            })
        end)
    end) -- Layer
end
