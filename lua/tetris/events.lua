local Events = {}
Events.__index = Events

---@class TetrisEvents
---@field listeners table<string, function[]>
---@field on fun(self, event: string, listener: function)
---@field off fun(self, event: string, listener: function)
---@field emit fun(self, event: string, ...)
function Events:new()
  return setmetatable({
    listeners = {},
  }, self)
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

return Events
