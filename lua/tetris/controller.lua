local utils = require("tetris.utils")

local Controller = {}
Controller.__index = Controller

---@class TetrisController
---@field constants TetrisConstants
---@field renderer TetrisRenderer
---@field state TetrisState
---@field pause fun(self)
---@field quit fun(self)
---@field reset fun(self)
function Controller:new(opts)
  opts = opts or {}

  return setmetatable({
    constants = opts.constants,
    renderer = opts.renderer,
    state = opts.state,
  }, self)
end

function Controller:pause()
  self.state.is_paused = not self.state.is_paused
end

function Controller:quit()
  self.state.is_paused = true
  self.state.is_quitting = true
  self.renderer:close_window()
end

function Controller:reset()
  self.state:reset()
end

function Controller:shape_drop()
  local can_move = true
  while can_move do
    can_move = self:attempt_change("down")
  end
  self:shape_lock()
end

function Controller:shape_lock()
  utils.add_to_field(
    self.constants,
    self.state,
    self.state.current_shape,
    self.state.current_x,
    self.state.current_y,
    self.state.current_rotation
  )

  self.state.current_shape = nil
  self.state.current_x = 0
  self.state.current_y = 0
  self.state.current_rotation = 0
end

function Controller:shape_move_down()
  self:attempt_change("down")
end

function Controller:shape_move_left()
  self:attempt_change("left")
end

function Controller:shape_move_right()
  self:attempt_change("right")
end

function Controller:shape_rotate()
  self:attempt_change("rotate")
end

function Controller:tick()
  --- Game loop/tick
end

--- TODO: reconsider this and where it lives
--- TODO: reconsider this and where it lives
--- TODO: reconsider this and where it lives
function Controller:attempt_change(change)
  if self.state.is_paused then
    return false
  end

  local dx, dy, dr = 0, 0, 0

  if change == "left" then
    dx = -1
  elseif change == "right" then
    dx = 1
  elseif change == "down" then
    dy = 1
  elseif change == "rotate" then
    dr = 1
  end

  if
    utils.can_move(
      self.constants,
      self.state,
      self.state.current_shape,
      self.state.current_x + dx,
      self.state.current_y + dy,
      self.state.current_rotation + dr
    )
  then
    self.state.current_x = self.state.current_x + dx
    self.state.current_y = self.state.current_y + dy
    self.state.current_rotation = self.state.current_rotation + dr
    return true
  end
end

return Controller
