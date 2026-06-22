---@class YarnProto
---@field start fun(self:Yarn)? Automatic entrypoint for when Yarn starts
---@field in_move fun(self:Yarn, params:{dx:integer,dy:integer,v:vector3})? Event: Player arrow/gamepad input, single event per tick with deltax/y [-1,1]
---@field [string] fun(self:Yarn, params:EventParams)? Other event handlers, parameters vary by event

---@class Yarn
---@field id integer Unique ID per Yarn [READONLY]
---@field is_dead bool? [READONLY]
---@field _next string? Queue of 1 event - FUTURE: more events?
---@field _next_params EventParams? Params for 1 event
---@field _coro thread?
---@field _cycler number
local Yarn = {}
local meta_Yarn = { __index = Yarn }
local id_order = 1

---@alias EventParams table<string,any>
local EMPTY_PARAMS = {}

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

-- You can override this in your new Yarn to make a simple fixed_update Yarn that does not use coroutines or events.
-- You may call it manually to speed ahead if you like.
---@return bool? done Returns true if Yarn is completely idle
function Yarn:run_tick()
    local coro = self._coro
    local params ---@type EventParams?

    -- Process event?
    local event = self._next
    if event then
        self._next = nil
        local fn = self[event] ---@type fun()?
        if type(fn) == 'function' then
            coro = coroutine.create(fn)
            self._coro = coro
            self._cycler = 0 -- Events happen immediately
            params = self._next_params or EMPTY_PARAMS
        end
        self._next_params = nil
    end

    -- Delays
    local cycler = self._cycler
    if cycler > 0 then
        self._cycler = cycler - 1
        return
    end

    -- Start or resume coroutine
    if coro then
        coroutine.resume(coro, self, params)
        local status = coroutine.status(coro)
        if status == 'dead' then
            -- FUTURE: could [optionally] loop back for another event (e.g. to support zero-delay "goto")
            -- (this could be flagged based on a yield return value, or just standard behavior)
            self._coro = nil
            -- UNNEEDED CURRENTLY: coro = nil
        end
        return
    end

    -- No events, idles, or ticks left to process
    return true
end

---@param ticks number?
---@async
function Yarn:idle(ticks)
    local coro = self._coro
    if not coro or coroutine.running() ~= coro then
        error('bad usage of idle') -- TODO: optionally non-fatal errors
        return
    end
    if ticks then -- TODO: if ticks is [0.0,1.0) don't yield?
        self._cycler = self._cycler + ticks - 1
    end
    coroutine.yield()
end

---@async
function Yarn:die()
    self.is_dead = true
    local coro = self._coro
    local status = coro and coroutine.status(coro)
    assert(status ~= 'normal', 'Undefined behavior: Yarn is running but not active') -- E.g. Yarn resumes another Yarn
    if status == 'running' then
        coroutine.yield() -- end cycle immediately
    end
end

---@param event string
---@param params EventParams?
function Yarn:send(event, params)
    if type(self[event]) == 'function' then
        self._next = event
        self._next_params = params
    end
end

return new_Yarn
