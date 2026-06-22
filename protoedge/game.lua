--
-- "Prototype game logic lives here"
--

local Screen = require('protoedge.screen')
local LayerBoss = require('protoedge.layer_boss')
local YarnBoss = require('protoedge.yarn_boss')
local SmoothInput = require('input.smooth_input')

local function the_game()
    -- Set up input handling
    local input = SmoothInput.new()

    -- Scrolling background
    local bg_layer = LayerBoss.new_layer{ width = Screen.COLS + 1 }
    local bg_yarn = YarnBoss.new_yarn{
        start = function(self)
            local t = 0
            repeat
                t = t + 1
                for x = 1, bg_layer.width do
                    for y = 1, bg_layer.height do
                        local i = x + y + t
                        -- local char = i % 256 + 1
                        bg_layer:poke(x, y, 149, (i + 1) % 29 + 1, i % 29 + 1)
                    end
                end
                for scroll = 8, 1, -1 do
                    bg_layer.x_col = scroll / 8
                    self:idle(4)
                end
            until false
        end,
    }

    -- Bouncing balls
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
        fg_layer[i] = LayerBoss.new_layer{ width = SPR_SIZE, height = SPR_SIZE, x_col = x, y_row = y }
        local color = i * 4 + 3
        -- fg_layer[i]:rect({ x = 1, y = 1, w = SPR_SIZE, h = SPR_SIZE }, { tile = 162, fg = color })
        fg_layer[i]:poke(1, 1, 145, color)
        fg_layer[i]:poke(2, 1, 147, color)
        fg_layer[i]:poke(1, 2, 177, color)
        fg_layer[i]:poke(2, 2, 179, color)
    end

    local fg_yarn = YarnBoss.new_yarn{
        start = function(self)
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
        end,
    }

    -- Box window
    local window = { x = 2, y = 2, w = Screen.COLS - 2, h = Screen.ROWS - 2 }
    local box_layer = LayerBoss.new_layer()
    box_layer:rect(window, { tile = 167, bg = 2 })
    box_layer:rect(window, { tile = 256, fg = 3 }, true)

    -- Cursor layer
    -- TODO: extract helper for Rect->Opts copying (note the param difference could help enforce patterns- x and x_col are not the same!)
    local view_width = window.w - 2
    local view_height = window.h - 2
    local cursor_layer = LayerBoss.new_layer{ x_col = window.x + 1, y_row = window.y + 1, width = 1, height = 1 }
    local cursor_x, cursor_y = 1, 1
    ---@param cell Cell
    local function draw_cursor(cell)
        cursor_layer:cell(1, 1, cell)
        cursor_layer.x_col = window.x + cursor_x
        cursor_layer.y_row = window.y + cursor_y
    end
    ---@type Cell
    local EMPTY_CELL = { tile = 0, fg = 0, bg = 0 } -- TODO: Move somewhere useful
    ---@type Cell[]
    local CURSOR_CELLS = {
        { tile = 253, fg = 12, bg = 23 },
        --{ tile = 253, fg = 4, bg = 23 },
    }
    local cursor_frame = 1
    ---@param self Yarn
    local function run_cursor(self)
        repeat
            draw_cursor(CURSOR_CELLS[cursor_frame])
            if cursor_frame < #CURSOR_CELLS then
                cursor_frame = cursor_frame + 1
            else
                cursor_frame = 1
            end
            self:idle(15)
        until false
    end
    local cursor_yarn = YarnBoss.new_yarn{
        start = function(self)
            run_cursor(self)
        end,
        in_move = function(self, params)
            draw_cursor(EMPTY_CELL)
            cursor_x = cursor_x + params.dx
            while cursor_x < 1 do cursor_x = cursor_x + view_width end
            while cursor_x > view_width do cursor_x = cursor_x - view_width end
            cursor_y = cursor_y + params.dy
            while cursor_y < 1 do cursor_y = cursor_y + view_height end
            while cursor_y > view_height do cursor_y = cursor_y - view_height end
            run_cursor(self)
        end,
    }
end

return the_game
