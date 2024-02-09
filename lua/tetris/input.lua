---@class TetrisInput
---@field setup fun(self, buffer: number, mappings: table<string, string>, events: TetrisEvents)
local Input = {}

function Input:new()
  local instance = setmetatable({}, Input)
  self.__index = self
  return instance
end

---@param buffer number
---@param mappings table<string, string>
---@param events TetrisEvents
function Input:setup(buffer, mappings, events)
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
