local Controller = {}
Controller.__index = Controller

---@class TetrisController
---@field constants TetrisConstants
---@field events TetrisEvents
---@field renderer TetrisRenderer
---@field state TetrisState
---@field pause fun(self)
---@field quit fun(self)
---@field reset fun(self)
function Controller:new(opts)
  opts = opts or {}

  return setmetatable({
    constants = opts.constants,
    events = opts.events,
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
  --- Drop the shape
end

function Controller:shape_move_down()
  --- Move the shape down
end

function Controller:shape_move_left()
  --- Move the shape to the left
end

function Controller:shape_move_right()
  --- Move the shape to the right
end

function Controller:shape_rotate()
  --- Rotate the shape
end

function Controller:tick()
  --- Game loop/tick
end

return Controller
