local popup = require("plenary.popup")

local tetris = {}

local function create_window()
  local height = 10
  local width = 60

  local bufnr = vim.api.nvim_create_buf(false, false)

  local tetris_win_id, win = popup.create(bufnr, {
    border = true,
    col = math.floor((vim.o.columns - width) / 2),
    highlight = "TetrisWindow",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    minheight = height,
    minwidth = width,
    noautocmd = true,
    title = "Tetris",
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = bufnr,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, tetris_win_id, true)
      pcall(vim.api.nvim_win_close, win.border.win_id, true)
      require("telescope.utils").buf_delete(bufnr)
    end,
  })

  -- add placeholder lines for score
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "Score: 0" })

  -- make buffer read only, no input
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- respond to key presses
  vim.api.nvim_buf_set_keymap(bufnr, "n", "h", "", { callback = tetris.move_left })

  return {
    bufnr = bufnr,
    win_id = tetris_win_id,
  }
end

-- TODO: NO
-- TODO: also, wtf is this tetris global business
tetris.close = function()
  vim.api.nvim_win_close(tetris.window.win_id, true)
end

tetris.move_left = function()
  print("left")
end

-- TODO: NO
-- TODO: also, wtf is this tetris global business
tetris.run = function()
  tetris.window = create_window()
  vim.api.nvim_buf_set_keymap(tetris.window.bufnr, "n", "<Esc>", "", { callback = tetris.close })
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
