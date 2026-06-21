-----------------------------------------------------------------------------------------
-- Input handler that produces continuous movement events
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Definition and construction
-----------------------------------------------------------------------------------------
---@class SmoothInputProto

---@class SmoothInput
local SmoothInput = {}
local meta_SmoothInput = { __index = SmoothInput }

---@class SmoothInputClass
local SmoothInputClass = {}

---@param opts SmoothInputProto?
---@return SmoothInput
function SmoothInputClass.new(opts)
local self = setmetatable(opts or {}, meta_SmoothInput) --[[@as SmoothInput]]
    return self
end

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

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

local pressed_this_frame = {}---@type table<hash,number>
local held_this_frame = {} ---@type table<hash,number>

---@param action_id hash
---@param action on_input.action
function SmoothInputClass.on_input(action_id, action)
    if type(action.value) ~= 
    if action.released then
    held_this_frame[action_id] = nil
    elseif action.pressed then
    held_this_frame[action_id] = action.value
    pressed_this_frame[action_id] = action.value
    else
    end

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

function SmoothInput:do_something()
    
end
