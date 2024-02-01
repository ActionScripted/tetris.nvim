local EventHandler = {}

function EventHandler:new()
  local instance = setmetatable({}, EventHandler)
  instance.listeners = {}
  self.__index = self
  return instance
end

---@param event string
---@param listener function
function EventHandler:on(event, listener)
  if not self.listeners[event] then
    self.listeners[event] = {}
  end
  table.insert(self.listeners[event], listener)
end

---@param event string
---@param listener function
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

---@param event string
---@param ... unknown
function EventHandler:emit(event, ...)
  if self.listeners[event] then
    for _, listener in ipairs(self.listeners[event]) do
      listener(...)
    end
  end
end

return EventHandler
