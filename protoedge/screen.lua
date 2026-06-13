local Screen = {
    WIDTH = 320,
    HEIGHT = 240,
    TILE_WIDTH = 8,
    TILE_HEIGHT = 8,
}
Screen.COLS = Screen.WIDTH / Screen.TILE_WIDTH
Screen.ROWS = Screen.HEIGHT / Screen.TILE_HEIGHT
Screen.LAST_COL = Screen.COLS - 1 -- 0-based
Screen.LAST_ROW = Screen.ROWS - 1
Screen.CELLS = Screen.COLS * Screen.ROWS

---@param x number On-screen X position in tiles, 1 is left edge of screen (decimals allowed)
---@param y number On-screen Y position in tiles, 1 is top edge of screen (decimals allowed)
---@param z number? Optional Z coordinate, defaults to 0
---@return vector3 pos Position for a Defold sprite representing this cell on-screen (i.e. the lower-left corner)
function Screen.tile_to_pos(x, y, z)
    x = (x - 1) * Screen.TILE_WIDTH
    y = (Screen.ROWS - y) * Screen.TILE_HEIGHT
    return vmath.vector3(x, y, z or 0)
end

return Screen
