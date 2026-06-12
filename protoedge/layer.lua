local Screen = require('protoedge.screen')

local Tilette = {}
Tilette.MIN = 1
Tilette.MAX = 155

local Palette = {
    -- ALGORITHMIC PALETTE (one of several built-in palettes)
    -- Black thru White
    vmath.vector4(0.0, 0.0, 0.0, 1.0),
    vmath.vector4(0.25, 0.25, 0.25, 1.0),
    vmath.vector4(0.5, 0.5, 0.5, 1.0),
    vmath.vector4(0.75, 0.75, 0.75, 1.0),
    vmath.vector4(1.0, 1.0, 1.0, 1.0),
    -- Red: 1/3rd, 2/3rd, full, full+50%
    vmath.vector4(0.33, 0.0, 0.0, 1.0),
    vmath.vector4(0.66, 0.0, 0.0, 1.0),
    vmath.vector4(1.0, 0.0, 0.0, 1.0),
    vmath.vector4(1.0, 0.5, 0.5, 1.0),
    -- Yellow
    vmath.vector4(0.33, 0.33, 0.0, 1.0),
    vmath.vector4(0.66, 0.66, 0.0, 1.0),
    vmath.vector4(1.0, 1.0, 0.0, 1.0),
    vmath.vector4(1.0, 1.0, 0.5, 1.0),
    -- Green
    vmath.vector4(0.0, 0.33, 0.0, 1.0),
    vmath.vector4(0.0, 0.66, 0.0, 1.0),
    vmath.vector4(0.0, 1.0, 0.0, 1.0),
    vmath.vector4(0.5, 1.0, 0.5, 1.0),
    -- Cyan
    vmath.vector4(0.0, 0.33, 0.33, 1.0),
    vmath.vector4(0.0, 0.66, 0.66, 1.0),
    vmath.vector4(0.0, 1.0, 1.0, 1.0),
    vmath.vector4(0.5, 1.0, 1.0, 1.0),
    -- Blue
    vmath.vector4(0.0, 0.0, 0.33, 1.0),
    vmath.vector4(0.0, 0.0, 0.66, 1.0),
    vmath.vector4(0.0, 0.0, 1.0, 1.0),
    vmath.vector4(0.5, 0.5, 1.0, 1.0),
    -- Magenta
    vmath.vector4(0.33, 0.0, 0.33, 1.0),
    vmath.vector4(0.66, 0.0, 0.66, 1.0),
    vmath.vector4(1.0, 0.0, 1.0, 1.0),
    vmath.vector4(1.0, 0.5, 1.0, 1.0),
    -- (2 spare slots)
}
Palette.Transparent = vmath.vector4(0, 0, 0, 0)

---@alias tile integer 0 is "nothing", 1+ for accessing tileset
---@alias color integer 0 is "transparent", 1+ for accessing palette

---@class Layer
---@field w integer Width in tiles
---@field h integer Height in tiles
-- TODO: change to tile-based position e.g. 1,1 floats upper-left corner
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
    local tile = self._tile
    local fg = self._fg
    local bg = self._bg
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

        local i_tile = tile[i]
        local cursor = (i_tile - Tilette.MIN) / (Tilette.MAX - Tilette.MIN)
        go.set(spr_url, "cursor", cursor)
        go.set(spr_url, "col0", Palette[bg[i]] or Palette.Transparent)
        go.set(spr_url, "col1", Palette[fg[i]] or Palette.Transparent)
    end
end

return new_Layer
