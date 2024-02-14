local Shape = {}
Shape.__index = Shape

---@class TetrisShapeTODO
---@field color string
---@field data string
---@field name string
---@field rotation number
---@field size number
---@field x number
---@field y number
function Shape:new(opts)
  opts = opts or {}

  return setmetatable({
    color = opts.color,
    data = opts.data,
    name = opts.name,
    rotation = opts.rotation or 0,
    size = opts.size,
    x = opts.x or 0,
    y = opts.y or 0,
  }, self)
end

return Shape
