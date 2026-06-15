-----------------------------------------------------------------------------------------
-- Converts raw input from Defold engine into discrete events
-----------------------------------------------------------------------------------------

local YarnBoss = require('protoedge.yarn_boss')

---@pkg InputBoss
local InputBoss = {}

local ANALOG_THRESHOLD = 0.75 -- Note that e.g. even with stick fully left/right you'll get a small amount up/down

local LEFT = hash('left')
local RIGHT = hash('right')
local UP = hash('up')
local DOWN = hash('down')

local DELTA_X = {
    [LEFT] = -1,
    [RIGHT] = 1,
    [UP] = 0,
    [DOWN] = 0,
}
local DELTA_Y = {
    [LEFT] = 0,
    [RIGHT] = 0,
    [UP] = -1,
    [DOWN] = 1,
}

---@param action_id hash
---@param action on_input.action
function InputBoss.on_input(action_id, action)
    if (action.pressed or action.repeated) and action.value > ANALOG_THRESHOLD then
        local dx = DELTA_X[action_id]
        if dx then
            local dy = DELTA_Y[action_id]
            -- FUTURE: diagonal support, analog support
            YarnBoss.send('in_move', { dx = dx, dy = dy })
        end
    end
    -- FUTURE: in_button, in_key, in_mouse
    -- FUTURE: un_move, un_button, un_key (full release)
end

return InputBoss
