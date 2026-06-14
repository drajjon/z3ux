--
-- "Prototype game logic lives here"
--

local Screen = require('protoedge.screen')
local LayerBoss = require('protoedge.layer_boss')
local YarnBoss = require('protoedge.yarn_boss')

local function the_game()
    local SPR_SIZE = 4
    local bg_layer = LayerBoss.new_layer()
    local fg_layer = LayerBoss.new_layer { width = SPR_SIZE, height = SPR_SIZE, x_col = 1.5, y_row = 1.5 }
    fg_layer:rect({ x = 1, y = 1, w = SPR_SIZE, h = SPR_SIZE }, { tile = 162, fg = 5 })

    local bg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            local t = 0
            repeat
                t = t + 1
                for x = 1, Screen.COLS do
                    for y = 1, Screen.ROWS do
                        local i = x + y + t
                        bg_layer:poke(x, y, i % 256 + 1, i % 31 + 1, i % 30 + 1)
                    end
                end
                bg_layer:rect({ x = 2, y = 2, w = Screen.COLS - 2, h = Screen.ROWS - 2 }, { tile = 188, fg = 5 }, true)
                self:idle(15)
            until false
        end
    }
    local fg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            local x_max = Screen.COLS - SPR_SIZE + 1
            local y_max = Screen.ROWS - SPR_SIZE + 1
            local x = math.random(1, x_max)
            local y = math.random(1, y_max)
            local x_d, y_d = 0.25, 0.25
            repeat
                x = x + x_d
                if x >= x_max or x <= 1 then x_d = -x_d end
                y = y + y_d
                if y >= y_max or y <= 1 then y_d = -y_d end
                fg_layer.x_col = x
                fg_layer.y_row = y
                self:idle()
            until false
        end
    }
end

return the_game
