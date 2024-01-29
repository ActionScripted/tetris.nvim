local events = require("tetris.events")
local input = {}

---@type table
local mappings = {
  ["<Down>"] = "down",
  ["<Esc>"] = "quit",
  ["<Left>"] = "left",
  ["<LeftMouse>"] = "noop",
  ["<MiddleMouse>"] = "noop",
  ["<Mouse>"] = "noop",
  ["<Right>"] = "right",
  ["<RightMouse>"] = "noop",
  ["<Up>"] = "rotate",
  h = "left",
  j = "down",
  k = "rotate",
  l = "right",
  p = "pause",
  q = "quit",
}

---@param buffer any
input.setup = function(buffer)
  for key, action in pairs(mappings) do
    if action == "noop" then
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "<Nop>", { noremap = true, silent = true })
    else
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "", {
        callback = function()
          events.emit(action, buffer)
        end,
      })
    end
  end
end

return input
