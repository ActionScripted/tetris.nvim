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

function State:setup()
  self.current_rotation = 0
  self.current_shape = nil
  self.current_x = 0
  self.current_y = 0
  self.drop_speed = 48
  self.is_paused = false
  self.is_quitting = false
  self.score = 0
  self.tick_count = 0
end

return State
