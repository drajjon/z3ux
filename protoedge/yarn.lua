---@class YarnProto
---@field start fun(self:Yarn)? Automatic entrypoint for when Yarn starts

---@class Yarn
---@field id integer Unique ID per Yarn [READONLY]
---@field _next string? Queue of 1 message - FUTURE: more messages
---@field _coro thread?
---@field _cycler number
local Yarn = {}
local meta_Yarn = { __index = Yarn }
local id_order = 1

---@param opts YarnProto?
---@return Yarn
local function new_Yarn(opts)
    local self = setmetatable(opts or {}, meta_Yarn) ---@class Yarn
    self.id = id_order
    id_order = id_order + 1
    self._cycler = 0
    self._next = 'start'
    return self
end

-- You can override this in your new Yarn to make a simple fixed_update Yarn that does not use coroutines.
-- You may call it manually to speed ahead if you like.
---@return bool? done Returns true if Yarn is completely idle
function Yarn:run_tick()
    -- Delays
    local cycler = self._cycler
    if cycler > 0 then
        self._cycler = cycler - 1
        return
    end

    -- Resume existing coroutine?
    local coro = self._coro
    if coro then
        coroutine.resume(coro, self)
        local status = coroutine.status(coro)
        if status == 'dead' then
            self._coro = nil -- Need a new coroutine
        end
        return
    end

    -- Process next message and spin up new coroutine
    local msg = self._next
    local fn = self[msg] ---@type fun()?
    self._next = nil
    if type(fn) ~= 'function' then
        -- End of message queue
        return true
    end
    coro = coroutine.create(fn)
    self._coro = coro -- (Yarn needs to know it's own coroutine while running)
    -- This code looks the same but we expect message processing to add parameters later
    coroutine.resume(coro, self)
    local status = coroutine.status(coro)
    if status == 'dead' then
        self._coro = nil
    end
end

---@param ticks number?
---@async
function Yarn:idle(ticks)
    local coro = self._coro
    if not coro or coroutine.running() ~= coro then
        error('bad usage of idle') -- TODO: optionally non-fatal errors
        return
    end
    if ticks then
        self._cycler = self._cycler + ticks - 1
    end
    coroutine.yield()
end

-- Safety default implementation, does nothing
---@async
function Yarn:start()
end

return new_Yarn
