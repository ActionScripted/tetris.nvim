local popup = require("plenary.popup")
local M = {}

M.window = {
  buffer = nil,
  height = 10,
  id = nil,
  width = 60,
}

M.create_window = function()
  M.window.buffer = vim.api.nvim_create_buf(false, true)

  local win_id, win = popup.create(M.window.buffer, {
    border = true,
    col = math.floor((vim.o.columns - M.window.width) / 2),
    highlight = "TetrisWindow",
    line = math.floor(((vim.o.lines - M.window.height) / 2) - 1),
    minheight = M.window.height,
    minwidth = M.window.width,
    noautocmd = true,
    title = "Tetris",
  })

  M.window.id = win_id

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = M.window.buffer,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win_id, true)
      pcall(vim.api.nvim_win_close, win.border.win_id, true)
      require("telescope.utils").buf_delete(M.window.buffer)
    end,
  })
end

return M
