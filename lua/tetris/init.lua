local async = require("plenary.async")
local popup = require("plenary.popup")

local tetris = {}

tetris.should_close = false

local function create_window()
  local height = 10
  local width = 60

  local bufnr = vim.api.nvim_create_buf(false, true)

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
  --vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "Score: 0" })

  -- make buffer read only, no input
  --vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- respond to key presses
  vim.api.nvim_buf_set_keymap(bufnr, "n", "h", "", { callback = tetris.move_left })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "", { callback = tetris.handle_quit })

  return {
    bufnr = bufnr,
    win_id = tetris_win_id,
  }
end

tetris.handle_quit = function()
  tetris.should_close = true
  print("closing...")
end

tetris.currentPosIndex = 1
tetris.positions = {
  { line = 0, col = 0 },
  { line = 0, col = 1 },
  { line = 1, col = 1 },
  { line = 1, col = 0 },
}

tetris.draw_game = function(buffer)
  -- Ensure each line is at least as long as the longest column index
  local lines = { " ", " " } -- Pre-filling lines with a space
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

  -- Get the current position
  local pos = tetris.positions[tetris.currentPosIndex]

  -- Draw the asterisk at the current position
  local character = "*" -- Your chosen character
  vim.api.nvim_buf_set_text(buffer, pos.line, pos.col, pos.line, pos.col, { character })

  -- Update to the next position, cycling back to start if at the end
  tetris.currentPosIndex = (tetris.currentPosIndex % #tetris.positions) + 1
  print("drawing")
end

tetris.loop = function()
  local gameSpeed = 200
  tetris.should_close = false -- Ensure this starts as false

  local function gameTick()
    if tetris.should_close then
      print("Game loop ending") -- Debug message
      return
    end

    -- Error handling
    local status, err = pcall(function()
      tetris.draw_game(tetris.window.bufnr)
    end)

    if not status then
      print("Error in game loop: " .. err) -- Print any errors
      return
    end

    -- Schedule the next tick
    -- TODO: https://neovim.io/doc/user/lua.html#vim.uv
    vim.defer_fn(gameTick, gameSpeed)
    print("Game tick scheduled") -- Debug message
  end

  -- Start the first tick
  gameTick()
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
  tetris.loop()
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
