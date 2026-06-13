--
-- "Prototype game logic lives here"
--

local Screen = require('protoedge.screen')
local LayerBoss = require('protoedge.layer_boss')
local YarnBoss = require('protoedge.yarn_boss')

local function the_game()
    local bg_layer = LayerBoss.new_layer()
    local fg_layer = LayerBoss.new_layer { width = 3, height = 3, x_col = 1.5, y_row = 1.5 }

    for x = 1, 3 do
        for y = 1, 3 do
            fg_layer:poke(x, y, 136, 5, 1)
        end
    end

    local bg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            local t = 0
            repeat
                t = t + 1
                for x = 1, Screen.COLS do
                    for y = 1, Screen.ROWS do
                        local i = x + y + t
                        bg_layer:poke(x, y, i % 155 + 1, i % 31 + 1, i % 30 + 1)
                    end
                end
                self:idle(15)
            until false
        end
    }
    local fg_yarn = YarnBoss.new_yarn {
        tick = function(self)
            local x_max = Screen.COLS - 3
            local y_max = Screen.ROWS - 3
            local x = math.random(1, x_max)
            local y = math.random(1, y_max)
            local x_d, y_d = 0.25, 0.25
            repeat
                x = x + x_d
                if x > x_max or x < 2 then x_d = -x_d end
                y = y + y_d
                if y > y_max or y < 2 then y_d = -y_d end
                fg_layer.x_col = x
                fg_layer.y_row = y
                self:idle()
            until false
        end
    }
end

return the_game
