---@class TetrisState
---@field current_rotation number
---@field current_shape TetrisShape
---@field current_x number
---@field current_y number
---@field drop_speed number
---@field is_paused boolean
---@field is_quitting boolean
---@field score number
---@field tick_count number
---@field setup fun(self)
---@field load fun(self)

local State = {}

function State:new()
  local instance = setmetatable({}, State)
  self.__index = self
  return instance
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
  self.current_rotation = 0
  self.current_shape = nil
  self.current_x = 0
  self.current_y = 0
  self.drop_speed = 48
  self.field = {}
  self.is_paused = false
  self.is_quitting = false
  self.score = 0
  self.tick_count = 0

  for r = 0, constants.field_height - 1 do
    for c = 0, constants.field_width - 1 do
      self.field[r * constants.field_width + c] = constants.field_empty
    end
  end
end

return State
