local new_Yarn = require('protoedge.yarn')

---@class YarnBoss
local YarnBoss = {}
local _yarns = {} ---@type Yarn[]

---@param opts YarnProto?
---@return Yarn
function YarnBoss.new_yarn(opts)
    local yarn = new_Yarn(opts)
    table.insert(_yarns, yarn)
    return yarn
end

function YarnBoss.tick()
    for _, yarn in ipairs(_yarns) do
        yarn:tick()
    end
end

return YarnBoss
