---@class YarnProto
---@field tick fun(self:Yarn)? Called or resumed once per tick, i.e. at 60 FPS

---@class Yarn
---@field id integer Unique ID per Yarn [READONLY]
---@field _coro thread?
local Yarn = {}
local meta_Yarn = { __index = Yarn }
local id_order = 1

---@param opts YarnProto?
---@return Yarn
local function new_Yarn(opts)
    local self = setmetatable(opts or {}, meta_Yarn) ---@class Yarn
    self.id = id_order
    id_order = id_order + 1
    return self
end

-- You can override this in your new Yarn to make a simple fixed_update Yarn that does not use coroutines.
-- You may call it manually to speed ahead if you like.
function Yarn:run_tick()
    local coro = self._coro
    if coro then
        local status = coroutine.status(coro)
        if status == 'dead' then
            coro = nil -- Need a new coroutine
        end
    end
    if not coro then
        coro = coroutine.create(self.tick)
        self._coro = coro
    end
    coroutine.resume(coro, self)
end

-- Safety default implementation, does nothing
function Yarn:tick()
end

return new_Yarn
