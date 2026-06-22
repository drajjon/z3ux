-----------------------------------------------------------------------------------------
-- Converts raw input from Defold engine into discrete events
-----------------------------------------------------------------------------------------

---@class IInputHandler
---@field on_input function
---@field tick function

---@pkg InputBoss
local InputBoss = {}
local input_handlers = {} ---@type table<IInputHandler>

---@param action_id hash
---@param action on_input.action
function InputBoss.on_input(action_id, action)
    for handler in pairs(input_handlers) do
        handler:on_input(action_id, action)
    end
end

function InputBoss.tick()
    for handler in pairs(input_handlers) do
        handler:tick()
    end
end

---@param input_handler IInputHandler
function InputBoss.register_handler(input_handler)
    input_handlers[input_handler] = true
end

---@param input_handler IInputHandler
function InputBoss.unregister_handler(input_handler)
    input_handlers[input_handler] = nil
end

return InputBoss
