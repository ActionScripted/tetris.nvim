local Field = {}
Field.__index = Field

---@class Field
---The field (board) of the game.
---
---@field data string|TetrisShape[]
---@field empty string
---@field height number
---@field width number
---
---@field add_shape fun(self: Field, shape: TetrisShape)
---@field reset fun(self: Field)
function Field:new(opts)
  opts = opts or {}

  return setmetatable({
    data = {},
    empty = opts.empty,
    height = opts.height,
    width = opts.width,
  }, self)
end

function Field:add_shape(shape)
  --- Add the shape to the field
end

function Field:reset()
  --- Reset the field
end
