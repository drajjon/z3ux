---@class YarnProto
---@field tick fun(self:Yarn)? Called once per tick, i.e. at 60 FPS

---@class Yarn
---@field id integer Unique ID per Yarn [READONLY]
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

-- You can override this in your new Yarn to make a simple fixed_update Yarn.
-- You may call it manually to speed ahead if you like.
-- The default implementation
function Yarn:tick()

end

return new_Yarn
