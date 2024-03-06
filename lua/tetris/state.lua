local State = {}
State.__index = State

---@class TetrisState
---@field current_rotation number
---@field current_shape TetrisShape
---@field current_x number
---@field current_y number
---@field drop_speed number
---@field field table
---@field is_paused boolean
---@field is_quitting boolean
---@field score number
---@field tick_count number
---@field setup fun(self)
---@field load fun(self)
function State:new()
  return setmetatable({
    current_rotation = 0,
    current_shape = nil,
    current_x = 0,
    current_y = 0,
    drop_speed = 48,
    field = {},
    is_paused = false,
    is_quitting = false,
    score = 0,
    tick_count = 0,
  }, self)
end

---TODO: Load saved state from file.
function State:load()
  print("Not implemented!")
end

---TODO: Save state to file.
function State:save()
  print("Not implemented!")
end

---@param constants TetrisConstants
function State:setup(constants)
  --- TODO: move to Field class
  --- TODO: ...or move that stuff here?! Field, shapes, etc.
  for r = 0, constants.field_height - 1 do
    for c = 0, constants.field_width - 1 do
      self.field[r * constants.field_width + c] = constants.field_empty
    end
  end
end

return State
