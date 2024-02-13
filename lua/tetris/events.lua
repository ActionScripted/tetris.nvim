local utils = require("tetris.utils")

---@class TetrisEvents
---@field listeners table<string, function[]>
---@field on fun(self, event: string, listener: function)
---@field off fun(self, event: string, listener: function)
---@field emit fun(self, event: string, ...)
---@field setup fun(self, constant: TetrisConstants, state: TetrisState, renderer: TetrisRenderer)
local Events = {}

function Events:new()
  local instance = setmetatable({}, self)
  instance.listeners = {}
  self.__index = self
  return instance
end

---@param event string
---@param listener function
function Events:on(event, listener)
  if not self.listeners[event] then
    self.listeners[event] = {}
  end
  table.insert(self.listeners[event], listener)
end

---@param event string
---@param listener function
function Events:off(event, listener)
  if not self.listeners[event] then
    return
  end
  for i, l in ipairs(self.listeners[event]) do
    if l == listener then
      table.remove(self.listeners[event], i)
      break
    end
  end
end

---@param event string
---@param ... unknown
function Events:emit(event, ...)
  if self.listeners[event] then
    for _, listener in ipairs(self.listeners[event]) do
      listener(...)
    end
  end
end

---@param constants TetrisConstants
---@param state TetrisState
---@param renderer TetrisRenderer
function Events:setup(constants, state, renderer)
  --- TODO: reconsider this and where it lives
  local function attempt_change(change)
    if state.is_paused then
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
        constants,
        state,
        state.current_shape,
        state.current_x + dx,
        state.current_y + dy,
        state.current_rotation + dr
      )
    then
      state.current_x = state.current_x + dx
      state.current_y = state.current_y + dy
      state.current_rotation = state.current_rotation + dr
      return true
    end
  end

  self:on("left", function()
    attempt_change("left")
  end)

  self:on("right", function()
    attempt_change("right")
  end)

  self:on("down", function()
    attempt_change("down")
  end)

  self:on("drop", function()
    local can_move = true
    while can_move do
      can_move = attempt_change("down")
    end

    utils.add_to_field(constants, state, state.current_shape, state.current_x, state.current_y, state.current_rotation)

    state.current_shape = nil
    state.current_x = 0
    state.current_y = 0
    state.current_rotation = 0
  end)

  self:on("rotate", function()
    attempt_change("rotate")
  end)

  self:on("pause", function()
    state.is_paused = not state.is_paused
  end)

  self:on("quit", function()
    state.is_quitting = true
    renderer:close_window()
  end)
end

return Events
