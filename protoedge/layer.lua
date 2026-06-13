local Screen = require('protoedge.screen')

--
-- (this section is stuff likely to extract elsewhere over time)
--

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

local TILE_FACTORY = msg.url('main', '/stuff', 'tilefactory')
local BASE_FACTORY = msg.url('main', '/stuff', 'basefactory')

---@alias tile integer 0 is "nothing", 1+ for accessing tileset
---@alias color integer 0 is "transparent", 1+ for accessing palette
---@alias goid hash

--
-- (end section)
--

---@class LayerProto
---@field width integer Width in tiles
---@field height integer Height in tiles
---@field x_col number On-screen X position in tiles, 1 is left edge of screen (decimals allowed)
---@field y_row number On-screen Y position in tiles, 1 is top edge of screen (decimals allowed)

---@class Layer
---@field width integer Width in tiles [READONLY]
---@field height integer Height in tiles [READONLY]
---@field x_col number On-screen X position in tiles, 1 is left edge of screen (decimals allowed)
---@field y_row number On-screen Y position in tiles, 1 is top edge of screen (decimals allowed)
---@field id integer Unique ID per Layer [READONLY]
---@field _sort float Ranged -1.0 thru 1.0, back-to-front [managed by LayerBoss]
---@field _tile tile[]
---@field _fg color[]
---@field _bg color[]
---@field _spr url[]
---@field _base_go goid?
local Layer = {}
local meta_Layer = { __index = Layer }
local id_order = 1
local sort_order = -1 -- CURRENTLY -1 thru 1

---@param opts LayerProto?
---@return Layer
local function new_Layer(opts)
    local self = setmetatable(opts or {}, meta_Layer) ---@class Layer
    self.width = self.width or Screen.COLS
    self.height = self.height or Screen.ROWS
    self.x_col = self.x_col or 1
    self.y_row = self.y_row or 1
    self.id = id_order
    id_order = id_order + 1
    self._sort = 0
    self._tile = {}
    self._fg = {}
    self._bg = {}
    self._spr = {}
    return self
end

---@param x integer X position of cell, 1 for left-most column
---@param y integer Y position of cell, 1 for top-most row
---@return integer cell_index Index into e.g. `self._tile` for given cell
function Layer:_cell(x, y)
    -- FUTURE: bounds checking?
    return self.width * (y - 1) + x
end

-- Reverses `Layer:_cell(...)`
---@param cell_index integer
---@return number x,number y
function Layer:_cell_to_xy(cell_index)
    cell_index = cell_index - 1
    local x = cell_index % self.width + 1
    local y = math.floor(cell_index / self.width) + 1
    return x, y
end

---@param cell_index integer The result from `Layer:_cell(...)` or a similarly-calculated value
---@return vector3 pos Position (on base GO) for Defold sprite representing this cell
function Layer:_cell_to_pos(cell_index)
    local x, y = self:_cell_to_xy(cell_index)
    x = (x - 1) * Screen.TILE_WIDTH
    y = (self.height - y) * Screen.TILE_HEIGHT
    return vmath.vector3(x, y, 0) -- Z value should always be 0, layering is done via base
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

function Layer:_get_base_pos()
    return Screen.tile_to_pos(self.x_col, self.y_row + self.height - 1, self._sort)
end

---@return hash?
function Layer:_get_and_reposition_base()
    local pos = self:_get_base_pos()
    local base_go = self._base_go
    if base_go then
        go.set_position(pos, base_go)
    else
        base_go = factory.create(BASE_FACTORY, pos)
        if not base_go then
            error('out of sprites')
        end
    end
    return base_go
end

-- Call once a frame
function Layer:update()
    local base = self:_get_and_reposition_base()
    if not base then return end

    local spr = self._spr
    local tile = self._tile
    local fg = self._fg
    local bg = self._bg
    local max_i = self:_cell(self.width, self.height)

    for i = 1, max_i do
        local spr_url = spr[i]
        if not spr_url then
            local goid = factory.create(TILE_FACTORY, self:_cell_to_pos(i))
            if not goid then
                error('out of sprites')
                return
            end
            go.set_parent(goid, base)
            spr_url = msg.url(nil, goid, 'tile')
            spr[i] = spr_url
        end

        local i_tile = tile[i]
        if i_tile and i_tile > 0 then
            local cursor = (i_tile - Tilette.MIN) / (Tilette.MAX - Tilette.MIN)
            go.set(spr_url, "cursor", cursor)
        end
        go.set(spr_url, "col0", Palette[bg[i]] or Palette.Transparent)
        go.set(spr_url, "col1", Palette[fg[i]] or Palette.Transparent)
    end
end

return new_Layer
