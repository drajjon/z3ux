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
---@field _held_this_frame table<hash,number>
local SmoothInput = {}
local meta_SmoothInput = { __index = SmoothInput }

---@class SmoothInputClass
local SmoothInputClass = {}

---@param opts SmoothInputProto?
---@return SmoothInput
function SmoothInputClass.new(opts)
    local self = setmetatable(opts or {}, meta_SmoothInput) --[[@as SmoothInput]]
    self._held_this_frame = {}
    InputBoss.register_handler(self)
    return self
end

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

local ANALOG_THRESHOLD = 0.1 -- Note that e.g. even with stick fully left/right you'll get a small amount up/down

---@alias direction 'left'|'right'|'up'|'down'
local LEFT = hash('left')
local RIGHT = hash('right')
local UP = hash('up')
local DOWN = hash('down')

local SPEED = 0.25

local DELTA_X = {
    [LEFT] = -1,
    [RIGHT] = 1,
}
local DELTA_Y = {
    [UP] = -1,
    [DOWN] = 1,
}

---@param action_id hash
---@param action on_input.action
function SmoothInput:on_input(action_id, action)
    if type(action.value) ~= 'number' then
        pprint('wtf - ', action)
        error('wtf')
        return
    end

    local held = self._held_this_frame
    if action.released then
        assert(action.value == 0)
        held[action_id] = nil
    elseif action.value > ANALOG_THRESHOLD then
        held[action_id] = math.max(action.value, held[action_id] or 0)
    else
        held[action_id] = nil
    end
end

function SmoothInput:tick()
    local dx, dy ---@type number?, number?
    for action_id, magnitude in pairs(self._held_this_frame) do
        dx = DELTA_X[action_id] and DELTA_X[action_id] * magnitude or dx
        dy = DELTA_Y[action_id] and DELTA_Y[action_id] * magnitude or dy
    end
    if dx or dy then
        local vec = vmath.normalize(vmath.vector3(dx or 0, dy or 0, 0)) * SPEED
        -- FUTURE: (digital) cyclic movement, stagger diagonals
        -- FUTURE: (analog) applying original magnitude, momentum/smoothing
        YarnBoss.send('in_move', { dx = vec.x, dy = vec.y, v = vec })
    end
end

-- FUTURE: in_button, in_key, in_mouse
-- FUTURE: un_move, un_button, un_key (full release)
return SmoothInputClass
