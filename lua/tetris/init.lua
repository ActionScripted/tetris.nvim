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
    title = "Tetris",
  })

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

-- TODO: NO
-- TODO: also, wtf is this tetris global business
tetris.run = function()
  tetris.window = create_window()
  vim.api.nvim_buf_set_keymap(tetris.window.bufnr, "n", "<Esc>", "<Cmd>q<CR>", {})
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
