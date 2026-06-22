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

local ANALOG_THRESHOLD = 0.1 -- Note that e.g. even with stick fully left/right you'll get a small amount up/down

local LEFT = hash('left')
local RIGHT = hash('right')
local UP = hash('up')
local DOWN = hash('down')

local DIST = 0.25

local DELTA_X = {
    [LEFT] = -DIST,
    [RIGHT] = DIST,
}
local DELTA_Y = {
    [UP] = -DIST,
    [DOWN] = DIST,
}

-- local pressed_this_frame = {} ---@type table<hash,number>
local held_this_frame = {} ---@type table<hash,number>

---@param action_id hash
---@param action on_input.action
function SmoothInput:on_input(action_id, action)
    if type(action.value) ~= 'number' then
        pprint('wtf - ', action)
        error('wtf')
        return
    end

    if action.released then
        held_this_frame[action_id] = nil
    elseif action.value > ANALOG_THRESHOLD then
        held_this_frame[action_id] = math.max(action.value, held_this_frame[action_id] or 0)
    else
        held_this_frame[action_id] = nil
    end
end

function SmoothInput:tick()
    local dx, dy ---@type number?, number?
    for action_id, magnitude in pairs(held_this_frame) do
        dx = DELTA_X[action_id] and DELTA_X[action_id] * magnitude or dx
        dy = DELTA_Y[action_id] and DELTA_Y[action_id] * magnitude or dy
    end
    if dx or dy then
        -- FUTURE: (digital) cyclic movement, stagger diagonals
        -- FUTURE: (analog) normalized diagonals, momentum/smoothing
        YarnBoss.send('in_move', { dx = dx or 0, dy = dy or 0 })
    end
end

-- FUTURE: in_button, in_key, in_mouse
-- FUTURE: un_move, un_button, un_key (full release)
return SmoothInputClass
