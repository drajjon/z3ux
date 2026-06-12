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

return Screen
