local EventHandler = {}

function EventHandler:new()
  local obj = {
    listeners = {},
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function EventHandler:on(event, listener)
  if not self.listeners[event] then
    self.listeners[event] = {}
  end
  table.insert(self.listeners[event], listener)
end

function EventHandler:off(event, listener)
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

function EventHandler:emit(event, ...)
  if not self.listeners[event] then
    return
  end
  for _, listener in ipairs(self.listeners[event]) do
    listener(...)
  end
end

return EventHandler
