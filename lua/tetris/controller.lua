local utils = require("tetris.utils")

local Controller = {}
Controller.__index = Controller

---@class TetrisController
---@field constants TetrisConstants
---@field renderer TetrisRenderer
---@field state TetrisState
---
---@field attempt_change fun(self, change: string): boolean
---@field pause fun(self)
---@field quit fun(self)
---@field restart fun(self)
---@field shape_drop fun(self)
---@field shape_lock fun(self)
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

function Controller:restart()
  self.state:reset(self.constants)
end

function Controller:shape_drop()
  if self.state.is_paused or self.state.is_game_over or not self.state.current_shape then
    return
  end

  self.state.current_y = utils.drop_y(
    self.constants,
    self.state,
    self.state.current_shape,
    self.state.current_x,
    self.state.current_y,
    self.state.current_rotation
  )
  self.state.stats.hard_drops = self.state.stats.hard_drops + 1
  self:shape_lock()
end

function Controller:shape_lock()
  if self.state.is_paused or self.state.is_game_over or not self.state.current_shape then
    return
  end

  utils.add_to_field(
    self.constants,
    self.state,
    self.state.current_shape,
    self.state.current_x,
    self.state.current_y,
    self.state.current_rotation
  )

  local pieces = self.state.stats.pieces
  pieces[self.state.current_shape.name] = (pieces[self.state.current_shape.name] or 0) + 1

  ---TODO: move this
  local lines = {}
  for sy = 0, self.state.current_shape.size - 1 do
    local field_y = sy + self.state.current_y

    local is_line = true
    for field_x = 0, self.constants.field_width - 1 do
      local field_index = self.constants.field_width * field_y + field_x

      if self.state.field[field_index] == self.constants.field_empty then
        is_line = false
        break
      end
    end

    if is_line then
      table.insert(lines, field_y)
    end
  end

  if #lines > 0 then
    self.state.stats.clears[#lines] = self.state.stats.clears[#lines] + 1
    self.state.score = math.clamp(
      self.state.score + self.constants.line_points[#lines] * (self.state.level + 1),
      self.constants.score_min,
      self.constants.score_max
    )
    self.state.top_score = math.max(self.state.score, self.state.top_score)
    self.state.lines_cleared = self.state.lines_cleared + #lines

    local level = math.floor(self.state.lines_cleared / self.constants.lines_per_level)
    if level > self.state.level then
      self.state.level = level
      self.state.gravity = self.constants.gravity[math.min(level + 1, #self.constants.gravity)]
    end
  end

  --- Pull everything above a cleared line down over it.
  for _, line in ipairs(lines) do
    for y = line, 1, -1 do
      for x = 0, self.constants.field_width - 1 do
        local field_index = self.constants.field_width * y + x
        local above_field_index = self.constants.field_width * (y - 1) + x
        self.state.field[field_index] = self.state.field[above_field_index]
      end
    end

    --- Row 0 has nothing to pull, just set empty.
    for x = 0, self.constants.field_width - 1 do
      self.state.field[x] = self.constants.field_empty
    end
  end

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

--- TODO: reconsider this and where it lives
--- TODO: reconsider this and where it lives
--- TODO: reconsider this and where it lives
function Controller:attempt_change(change)
  if self.state.is_paused or self.state.is_game_over or not self.state.current_shape then
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
    not utils.can_move(
      self.constants,
      self.state,
      self.state.current_shape,
      self.state.current_x + dx,
      self.state.current_y + dy,
      self.state.current_rotation + dr
    )
  then
    return false
  end

  self.state.current_x = self.state.current_x + dx
  self.state.current_y = self.state.current_y + dy
  self.state.current_rotation = self.state.current_rotation + dr

  self.state.stats.moves = self.state.stats.moves + math.abs(dx)
  self.state.stats.rotations = self.state.stats.rotations + dr

  if self.state.current_y > self.state.lowest_y then
    self.state.lowest_y = self.state.current_y
    self.state.lock_resets = 0
  elseif self.state.lock_ticks > 0 and self.state.lock_resets < self.constants.lock_resets_max then
    self.state.lock_resets = self.state.lock_resets + 1
    self.state.lock_ticks = 0
  end

  return true
end

return Controller
