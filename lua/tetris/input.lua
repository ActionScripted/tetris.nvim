local input = {}

input.mappings = {
  h = "left",
  j = "down",
  k = "rotate",
  l = "right",
  p = "pause",
  q = "quit",
  ["<Esc>"] = "quit",
}

input.setup_keys = function(buffer, handlers)
  for key, action in pairs(input.mappings) do
    vim.api.nvim_buf_set_keymap(buffer, "n", key, "", { callback = handlers[action] })
  end
end

input.setup_mouse = function(buffer, handlers)
  local mouse_events = { "<LeftMouse>", "<RightMouse>", "<MiddleMouse>", "<Mouse>" }
  for _, event in ipairs(mouse_events) do
    vim.api.nvim_buf_set_keymap(buffer, "n", event, "<Nop>", { noremap = true, silent = true })
  end
end

return input
