local input = {}

---@type table
input.mappings = {
  ["<Esc>"] = "quit",
  ["<LeftMouse>"] = "noop",
  ["<MiddleMouse>"] = "noop",
  ["<Mouse>"] = "noop",
  ["<RightMouse>"] = "noop",
  h = "left",
  j = "down",
  k = "rotate",
  l = "right",
  p = "pause",
  q = "quit",
}

---@param buffer any
---@param handlers any
input.setup = function(buffer, handlers)
  for key, action in pairs(input.mappings) do
    if action == "noop" then
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "<Nop>", { noremap = true, silent = true })
    else
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "", { callback = handlers[action] })
    end
  end
end

return input
