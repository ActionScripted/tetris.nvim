local layouts = require("tetris.layouts")

local ui = {
  window = {
    buffer = nil,
    height = 23,
    id = nil,
    width = 37,
  },
}

ui.create_window = function()
  ui.window.buffer = vim.api.nvim_create_buf(false, true)

  -- local win_id, win = popup.create(ui.window.buffer, {
  --   border = false,
  --   col = math.floor((vim.o.columns - ui.window.width) / 2),
  --   line = math.floor(((vim.o.lines - ui.window.height) / 2) - 1),
  -- })

  local win_id = vim.api.nvim_open_win(ui.window.buffer, true, {
    col = math.floor((vim.o.columns - ui.window.width) / 2),
    height = ui.window.height,
    relative = "editor",
    row = math.floor(((vim.o.lines - ui.window.height) / 2) - 1),
    style = "minimal",
    width = ui.window.width,
  })

  ui.window.id = win_id

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = ui.window.buffer,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win_id, true)
      --pcall(vim.api.nvim_win_close, win.border.win_id, true)
      -- TODO: require telescope
      require("telescope.utils").buf_delete(ui.window.buffer)
    end,
  })
end

---Fill/flood the game window with empty spaces.
---We CANNOT write to specific lines/cols in the buffer without there
---already being text there. So we flood the area to avoid errors.
ui.flood_window = function()
  local lines = {}
  for _ = 1, ui.window.height do
    table.insert(lines, string.rep(" ", ui.window.width))
  end
  vim.api.nvim_buf_set_lines(ui.window.buffer, 0, -1, false, lines)
end

---Draw our main layout to our main buffer.
ui.draw_layout_main = function()
  vim.api.nvim_buf_set_lines(ui.window.buffer, 0, -1, false, layouts.main())
end

return ui
