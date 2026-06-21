-----------------------------------------------------------------------------------------
-- Input handler that produces continuous movement events
-----------------------------------------------------------------------------------------
local YarnBoss = require('protoedge.yarn_boss')
local InputBoss = require('input.input_boss')

-----------------------------------------------------------------------------------------
-- Definition and construction
-----------------------------------------------------------------------------------------
---@class SmoothInputProto

---@class SmoothInput: IInputHandler
local SmoothInput = {}
local meta_SmoothInput = { __index = SmoothInput }

---@class SmoothInputClass
local SmoothInputClass = {}

---@param opts SmoothInputProto?
---@return SmoothInput
function SmoothInputClass.new(opts)
    local self = setmetatable(opts or {}, meta_SmoothInput) --[[@as SmoothInput]]
    InputBoss.register_handler(self)
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

-- local pressed_this_frame = {} ---@type table<hash,number>
local held_this_frame = {} ---@type table<hash,number>

---@param action_id hash
---@param action on_input.action
function SmoothInput:on_input(action_id, action)
    if type(action.value) ~= 'number' then
        pprint('wtf - ', action)
        return
    end

    if action.released then
        held_this_frame[action_id] = nil
    elseif action.value > ANALOG_THRESHOLD then
        held_this_frame[action_id] = math.max(action.value, held_this_frame[action_id] or 0)
    end
end

function SmoothInput:tick()
    local dx, dy = 0, 0
    for action_id, magnitude in pairs(held_this_frame) do
        dx = dx == 0 and DELTA_X[action_id] or dx
        dy = dy == 0 and DELTA_Y[action_id] or dy
    end
    -- FUTURE: stagger diagonals, analog support, normalized diagonals
    YarnBoss.send('in_move', { dx = dx, dy = dy })
end

-- FUTURE: in_button, in_key, in_mouse
-- FUTURE: un_move, un_button, un_key (full release)
return SmoothInputClass
