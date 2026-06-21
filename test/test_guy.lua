-- 3:00pm - 3:40pmish

local NUM_CELLS = 6
local FILL_SIZE = 2
local NUM_MOVES = 6
local COLORS = 'ROYGBV'
local NUM_COLORS = COLORS:len()

---@alias Board string[]

---@return Board
local function gen_board()
    local board = {} ---@type Board
    for i = 1, NUM_CELLS do
        local cell = ''
        for _ = 1, FILL_SIZE do
            local color = math.random(1, NUM_COLORS)
            cell = cell .. COLORS:sub(color, color)
        end
        board[i] = cell
    end
    return board
end

---@generic T
---@generic U
---@param src table<T,U>
---@return table<T,U>
local function copy(src)
    local dest = {} --@type table<T,U>
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest
end

---@param board Board
---@param src_pick integer
---@param hand string
---@return Board[]
local function give_drops(board, src_pick, hand)
    local hand_len = hand:len()
    if hand_len == 0 then return { board } end

    local results = {} ---@type Board[]
    local pick = src_pick % NUM_CELLS + 1 -- Next pick clockwise
    -- optionally skip "full" cells
    local dest_cell = board[pick]
    if dest_cell:len() >= 2 and dest_cell:sub(1, 1):rep(dest_cell:len()) == dest_cell then
        pprint('SKIP', src_pick, board)
        results = give_drops(board, pick, hand)
    end
    for drop_i = 1, hand_len do -- Try all possible drops
        local drop = hand:sub(drop_i, drop_i)
        local new_hand = hand:sub(drop_i + 1) .. (drop_i > 1 and hand:sub(1, drop_i - 1) or '')
        local new_board = copy(board)
        new_board[pick] = new_board[pick] .. drop

        local boards = give_drops(new_board, pick, new_hand)
        for _, b in ipairs(boards) do
            table.insert(results, b)
        end
    end
    return results
end

---@param board Board
---@param pick integer
---@return Board[]
local function take_moves(board, pick)
    board = copy(board)
    local hand = board[pick]
    board[pick] = ''
    return give_drops(board, pick, hand)
end

---@param board Board
---@return bool
local function is_winner(board)
    local found = {} ---@type table<string, integer>
    for i = 1, NUM_CELLS do
        local cell = board[i]
        for n = 1, cell:len() do
            local test = cell:sub(n, n)
            if found[test] and found[test] ~= i then
                return false
            end
            found[test] = i
        end
    end
    return true
end

---@param orig_board Board
local function try_solve(orig_board)
    local prev_boards = { orig_board }
    pprint('SOLVE', orig_board)
    for move = 1, NUM_MOVES do -- Take up to N moves
        local results = {} ---@type Board[]
        for _, board in ipairs(prev_boards) do -- Each move, start from each prior possible outcome
            -- New permutations from this move
            for pick = 1, NUM_CELLS do -- Pick from each possible cell
                if board[pick]:len() > 0 then
                    local boards = take_moves(board, pick)
                    for _, b in ipairs(boards) do
                        -- Check for a winner
                        if is_winner(b) then
                            pprint('WINNER', b)
                        else
                            table.insert(results, b)
                        end
                    end
                end
            end
        end
        pprint('BECOMES', results[1])
        prev_boards = results
    end
end

local function test_guy()
    local board = gen_board()
    try_solve(board)
end
