local new_Yarn = require('protoedge.yarn')

---@pkg YarnBoss
local YarnBoss = {}
local _yarns = {} ---@type Yarn[]

---@param opts YarnProto?
---@return Yarn
function YarnBoss.new_yarn(opts)
    local yarn = new_Yarn(opts)
    table.insert(_yarns, yarn)
    return yarn
end

-- TEMPORARY: We want a way for "done" yarns to clean out, but we haven't decided on the ideal method for that yet.
local DROP_YARNS = false

function YarnBoss.tick()
    local max_i = #_yarns
    local drop_i = 1
    for i = 1, max_i do
        local yarn = _yarns[i]
        local done = yarn:run_tick() and DROP_YARNS
        if not done then
            _yarns[drop_i] = yarn
            drop_i = drop_i + 1
        end
    end
    for i = drop_i, max_i do
        _yarns[i] = nil
    end
end

---@param event string
---@param params EventParams?
function YarnBoss.send(event, params)
    for _, yarn in ipairs(_yarns) do
        yarn:send(event, params)
    end
end

return YarnBoss
