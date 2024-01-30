local EventHandler = {}
local listeners = {}

---@param event string
---@param listener function
EventHandler.on = function(event, listener)
  if not listeners[event] then
    listeners[event] = {}
  end
  table.insert(listeners[event], listener)
end

---@param event string
---@param listener function
EventHandler.off = function(event, listener)
  if not listeners[event] then
    return
  end
  for i, l in ipairs(listeners[event]) do
    if l == listener then
      table.remove(listeners[event], i)
      break
    end
  end
end

---@param event string
---@param ... unknown
EventHandler.emit = function(event, ...)
  if listeners[event] then
    for _, listener in ipairs(listeners[event]) do
      listener(...)
    end
  end
end

return EventHandler
