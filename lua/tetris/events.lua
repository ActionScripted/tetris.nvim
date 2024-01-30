local EventHandler = {}
local listeners = {}

---@param event any
---@param listener any
function EventHandler.on(event, listener)
  if not listeners[event] then
    listeners[event] = {}
  end
  table.insert(listeners[event], listener)
end

---@param event any
---@param listener any
function EventHandler.off(event, listener)
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

---@param event any
---@param ... unknown
function EventHandler.emit(event, ...)
  if listeners[event] then
    for _, listener in ipairs(listeners[event]) do
      listener(...)
    end
  end
end

return EventHandler
