--
-- "Prototype game logic lives here"
--

local Screen = require('protoedge.screen')
local LayerBoss = require('protoedge.layer_boss')
local YarnBoss = require('protoedge.yarn_boss')

local function the_game()
    local bg_layer = LayerBoss.new_layer { width = Screen.COLS + 1 }
    local box_layer = LayerBoss.new_layer()
    box_layer:rect({ x = 2, y = 2, w = Screen.COLS - 2, h = Screen.ROWS - 2 }, { tile = 255, fg = 2 })
    box_layer:rect({ x = 2, y = 2, w = Screen.COLS - 2, h = Screen.ROWS - 2 }, { tile = 256, fg = 5 }, true)

    local bg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            local t = 0
            repeat
                t = t + 1
                for x = 1, bg_layer.width do
                    for y = 1, bg_layer.height do
                        local i = x + y + t
                        bg_layer:poke(x, y, i % 256 + 1, i % 31 + 1, i % 30 + 1)
                    end
                end
                for scroll = 8, 1, -1 do
                    bg_layer.x_col = scroll / 8
                    self:idle(2)
                end
            until false
        end
    }

    local SPR_SIZE = 2
    local NUM_SPR = 8
    local x_max = Screen.COLS - SPR_SIZE + 1
    local y_max = Screen.ROWS - SPR_SIZE + 1
    local fg_layer = {} ---@type Layer[]
    local x_d = {} ---@type number[]
    local y_d = {} ---@type number[]
    for i = 1, NUM_SPR do
        local x = math.random(2, x_max - 1)
        local y = math.random(2, y_max - 1)
        x_d[i] = ((math.random(1, 2) - 1) * 2 - 1) * 0.25
        y_d[i] = ((math.random(1, 2) - 1) * 2 - 1) * 0.25
        fg_layer[i] = LayerBoss.new_layer { width = SPR_SIZE, height = SPR_SIZE, x_col = x, y_row = y }
        local color = math.random(1, 30)
        -- fg_layer[i]:rect({ x = 1, y = 1, w = SPR_SIZE, h = SPR_SIZE }, { tile = 162, fg = color })
        fg_layer[i]:poke(1, 1, 145, color)
        fg_layer[i]:poke(2, 1, 147, color)
        fg_layer[i]:poke(1, 2, 177, color)
        fg_layer[i]:poke(2, 2, 179, color)
    end

    local fg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            repeat
                for i = 1, NUM_SPR do
                    local layer = fg_layer[i]
                    local x = layer.x_col
                    local y = layer.y_row
                    x = x + x_d[i]
                    if x >= x_max or x <= 1 then x_d[i] = -x_d[i] end
                    y = y + y_d[i]
                    if y >= y_max or y <= 1 then y_d[i] = -y_d[i] end
                    layer.x_col = x
                    layer.y_row = y
                end
                self:idle()
            until false
        end
    }
end

return the_game
