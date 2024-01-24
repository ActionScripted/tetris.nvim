---local async = require("plenary.async")

local tetris = {
  input = require("tetris.input"),
  should_close = false,
  speed = 200,
  ui = require("tetris.ui"),
}

tetris.handlers = {}

tetris.handlers.left = function()
  print("left")
end

tetris.handlers.down = function()
  print("down")
end

tetris.handlers.rotate = function()
  print("rotate")
end

tetris.handlers.right = function()
  print("right")
end

tetris.handlers.pause = function()
  print("pause")
end

tetris.handlers.quit = function()
  tetris.should_close = true
  vim.api.nvim_win_close(tetris.ui.window.id, true)
end

tetris.currentPosIndex = 1
tetris.positions = {
  { line = 0, col = 0 },
  { line = 0, col = 1 },
  { line = 1, col = 1 },
  { line = 1, col = 0 },
  { line = 2, col = 5 },
}

local function getCharWidth(char)
  local byte = string.byte(char)
  if byte >= 0 and byte <= 127 then
    return 1 -- Standard ASCII
  else
    return 2 -- Common width for non-ASCII characters
  end
end

tetris.draw_game = function(buffer)
  if not vim.api.nvim_buf_is_valid(tetris.ui.window.buffer) then
    print("Invalid buffer number. Exiting game loop.")
    return
  end

  -- -- Ensure each line is at least as long as the longest column index
  -- local lines = { " ", " " } -- Pre-filling lines with a space
  -- vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  tetris.ui.flood_window()

  -- Get the current position
  local pos = tetris.positions[tetris.currentPosIndex]

  -- Draw the asterisk at the current position
  -- https://symbl.cc/en/unicode/table/#block-elements
  local character = "▣"
  vim.api.nvim_buf_set_text(buffer, pos.line, pos.col, pos.line, pos.col + 1, { character })

  -- NOTE: Unicode widths make this necessary
  local char_width = getCharWidth(character)
  vim.api.nvim_buf_add_highlight(buffer, -1, "TetrisBlock", pos.line, pos.col, pos.col + char_width + 1)

  -- Update to the next position, cycling back to start if at the end
  tetris.currentPosIndex = (tetris.currentPosIndex % #tetris.positions) + 1
  print("drawing")
end

tetris.loop = function()
  tetris.should_close = false -- Ensure this starts as false

  local function gameTick()
    if tetris.should_close then
      print("Game loop ending") -- Debug message
      return
    end

    -- Error handling
    local status, err = pcall(function()
      tetris.draw_game(tetris.ui.window.buffer)
    end)

    if not status then
      print("Error in game loop: " .. err) -- Print any errors
      return
    end

    -- Schedule the next tick
    -- TODO: https://neovim.io/doc/user/lua.html#vim.uv
    vim.defer_fn(gameTick, tetris.speed)
    print("Game tick scheduled") -- Debug message
  end

  -- Start the first tick
  gameTick()
end

-- TODO: NO
-- TODO: also, wtf is this tetris global business
tetris.run = function()
  -- TODO: NOT HERE
  vim.api.nvim_set_hl(0, "TetrisBlock", { fg = "white", bg = "red" })

  -- Create UI
  tetris.ui.create_window()

  -- Setup input (bindings)
  tetris.input.setup(tetris.ui.window.buffer, tetris.handlers)

  -- Start game (loop)
  tetris.loop()
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
