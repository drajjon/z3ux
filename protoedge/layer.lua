local Screen = require('protoedge.screen')

---@alias tile integer 0 is "nothing", 1+ for accessing tileset
---@alias color integer 0 is "transparent", 1+ for accessing palette

---@class Layer
---@field w integer Width in tiles
---@field h integer Height in tiles
-- TODO: not sure about 0,0/lower-left here
---@field x integer On-screen X position in pixels, 0 is left edge of screen
---@field y integer On-screen Y position in pixels, 0 is bottom edge of screen
---@field _tile tile[]
---@field _fg color[]
---@field _bg color[]
---@field _spr url[]
local Layer = {}
local meta_Layer = { __index = Layer }

---@return Layer
local function new_Layer()
    local layer = setmetatable({}, meta_Layer) ---@class Layer
    layer.w = Screen.COLS
    layer.h = Screen.ROWS
    layer.x = 0
    layer.y = 0
    layer._tile = {}
    layer._fg = {}
    layer._bg = {}
    layer._spr = {}
    return layer
end

---@param x integer X position of cell, 1 for left-most column
---@param y integer Y position of cell, 1 for top-most row
---@return integer cell_index Index into e.g. `self._tile` for given cell
function Layer:_cell(x, y)
    -- FUTURE: bounds checking?
    return self.w * (y - 1) + x
end

-- Reverses `Layer:_cell(...)`
---@param cell_index integer
---@return number x,number y
function Layer:_cell_to_coord(cell_index)
    cell_index = cell_index - 1
    local x = cell_index % self.w + 1
    local y = math.floor(cell_index / self.w) + 1
    return x, y
end

---@param cell_index integer The result from `Layer:_cell(...)` or a similarly-calculated value
---@return number x,number y Screen position for sprite representing this cell
function Layer:_cell_to_screen(cell_index)
    local x, y = self:_cell_to_coord(cell_index)
    return (x - 1) * Screen.TILE_WIDTH, (Screen.ROWS - y) * Screen.TILE_HEIGHT
end

---@param x integer X position of cell, 1 for left-most column
---@param y integer Y position of cell, 1 for top-most row
---@param tile tile? Tile to place in cell (0 to clear cell, nil to leave existing tile alone)
---@param fg color? Foreground color for cell (0 for transparent, nil to leave existing fg alone)
---@param bg color? Background color for cell (0 for transparent, nil to leave existing bg alone)
function Layer:poke(x, y, tile, fg, bg)
    -- TODO: #if DEBUG?
    assert(type(x) == 'number') -- etc.

    local i = self:_cell(x, y)
    if tile then self._tile[i] = tile end
    if fg then self._fg[i] = fg end
    if bg then self._bg[i] = bg end
end

-- Call once a frame
function Layer:update()
    local factory_url = msg.url('/stuff#tilefactory')
    local spr = self._spr
    local max_i = self:_cell(self.w, self.h)

    for i = 1, max_i do
        local spr_url = spr[i]
        if not spr_url then
            local spr_x, spr_y = self:_cell_to_screen(i) -- TODO: vec3?
            local go_id = factory.create(factory_url, vmath.vector3(spr_x, spr_y, 0.0))
            if not go_id then
                error('out of sprites')
            end

            spr_url = msg.url(nil, go_id, 'tile')
            spr[i] = spr_url
        end

        -- TODO: use real data obviously
        go.set(spr_url, "cursor", math.random()) -- tile 1 thru 155 currently
        go.set(spr_url, "col0", vmath.vector4(math.random(), math.random(), math.random(), 1.0))
        go.set(spr_url, "col1", vmath.vector4(math.random(), math.random(), math.random(), 1.0))
    end
end

return new_Layer
