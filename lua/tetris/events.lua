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
  self:on("left", function()
    if not state.is_paused then
      if
        utils.can_move(
          constants,
          state,
          state.current_shape,
          state.current_x - 1,
          state.current_y,
          state.current_rotation
        )
      then
        state.current_x = state.current_x - 1
      end
    end
  end)

  self:on("right", function()
    if not state.is_paused then
      if
        utils.can_move(
          constants,
          state,
          state.current_shape,
          state.current_x + 1,
          state.current_y,
          state.current_rotation
        )
      then
        state.current_x = state.current_x + 1
      end
    end
  end)

  self:on("drop", function()
    if not state.is_paused then
      print("drop")
    end
  end)

  self:on("rotate", function()
    if not state.is_paused then
      if
        utils.can_move(
          constants,
          state,
          state.current_shape,
          state.current_x,
          state.current_y,
          state.current_rotation + 1
        )
      then
        state.current_rotation = state.current_rotation + 1
      end
    end
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
