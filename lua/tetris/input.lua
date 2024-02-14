local Input = {}
Input.__index = Input

---@class TetrisInput
function Input:new(opts)
  opts = opts or {}
  return setmetatable(opts or {}, Input)
end

---@param buffer number
---@param mappings table<string, string>
---@param events TetrisEvents
function Input:map_actions(buffer, mappings, events)
  for key, action in pairs(mappings) do
    if action == "noop" then
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "<Nop>", { noremap = true, silent = true })
    else
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "", {
        callback = function()
          events:emit(action, buffer)
        end,
      })
    end
  end
end

return Input
