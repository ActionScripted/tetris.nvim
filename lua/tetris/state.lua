local State = {}
State.__index = State

---@class TetrisState
---@field current_rotation number
---@field current_shape TetrisShape
---@field current_x number
---@field current_y number
---@field gravity number
---@field gravity_ticks number
---@field field table
---@field is_game_over boolean
---@field is_paused boolean
---@field is_quitting boolean
---@field level number
---@field lines_cleared number
---@field lock_resets number
---@field lock_ticks number
---@field lowest_y number
---@field next_shape TetrisShape
---@field score number
---@field top_score number
---
---@field load fun(self)
---@field reset fun(self, constants: TetrisConstants)
---@field save fun(self)
---
---@param constants TetrisConstants
function State:new(constants)
  local state = setmetatable({ top_score = 0 }, self)
  state:reset(constants)
  return state
end

---TODO: Load saved state from file.
function State:load()
  print("Not implemented!")
end

---@param constants TetrisConstants
function State:reset(constants)
  self.current_rotation = 0
  self.current_shape = nil
  self.current_x = 0
  self.current_y = 0
  self.gravity = constants.gravity[1]
  self.gravity_ticks = 0
  self.field = {}
  self.is_game_over = false
  self.is_paused = false
  self.is_quitting = false
  self.level = 0
  self.lines_cleared = 0
  self.lock_resets = 0
  self.lock_ticks = 0
  self.lowest_y = 0
  self.next_shape = nil
  self.score = 0

  --- TODO: move to Field class
  --- TODO: ...or move that stuff here?! Field, shapes, etc.
  for r = 0, constants.field_height - 1 do
    for c = 0, constants.field_width - 1 do
      self.field[r * constants.field_width + c] = constants.field_empty
    end
  end
end

---TODO: Save state to file.
function State:save()
  print("Not implemented!")
end

return State
