---local async = require("plenary.async")
require("tetris.math")
local events = require("tetris.events")

local tetris = {
  game_speed = 16,
  input = require("tetris.input"),
  level_speed = 100,
  level_ticks = 0,
  score = 0,
  score_max = 99999999,
  score_min = 0,
  should_close = false,
  ui = require("tetris.ui"),
  -- DNU
  current_pos = 3,
}

events.on("quit", function()
  tetris.should_close = true
  vim.api.nvim_win_close(tetris.ui.window.id, true)
end)

events.on("left", function()
  tetris.current_pos = tetris.current_pos - 1
end)

events.on("right", function()
  tetris.current_pos = tetris.current_pos + 1
end)

tetris.draw_game = function(buffer)
  if not vim.api.nvim_buf_is_valid(tetris.ui.window.buffer) then
    --print("Invalid buffer number. Exiting game loop.")
    return
  end

  -- -- Ensure each line is at least as long as the longest column index
  -- local lines = { " ", " " } -- Pre-filling lines with a space
  -- vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  tetris.ui.draw_layout_main()

  -- TODO: ew
  tetris.score = math.clamp(tetris.score + 10, tetris.score_min, tetris.score_max)

  -- TODO: keep positions (row,col) for this in layout, probably
  vim.api.nvim_buf_set_extmark(tetris.ui.window.buffer, tetris.namespace, 4, 31, {
    virt_text = { { tostring(tetris.score), "TetrisScore" } },
    virt_text_pos = "overlay",
  })

  vim.api.nvim_buf_set_extmark(tetris.ui.window.buffer, tetris.namespace, 7, 31, {
    virt_text = { { tostring(tetris.score), "TetrisScore" } },
    virt_text_pos = "overlay",
  })

  -- Get the current position
  tetris.current_pos = math.clamp(tetris.current_pos, 3, 26)

  -- Draw the asterisk at the current position
  -- https://symbl.cc/en/unicode/table/#block-elements
  local character = "▣"
  vim.api.nvim_buf_set_extmark(buffer, tetris.namespace, 3, tetris.current_pos, {
    virt_text = { { character, "TetrisBlock" } },
    virt_text_pos = "overlay",
  })

  -- Fix (faux hide) cursor
  vim.api.nvim_win_set_cursor(tetris.ui.window.id, { 2, tetris.ui.window.width })

  --print("drawing")
end

tetris.loop = function()
  tetris.should_close = false -- Ensure this starts as false

  local function gameTick()
    if tetris.should_close then
      --print("Game loop ending") -- Debug message
      return
    end

    -- Error handling
    local status, err = pcall(function()
      tetris.draw_game(tetris.ui.window.buffer)
    end)

    if not status then
      --print("Error in game loop: " .. err) -- Print any errors
      return
    end

    -- Schedule the next tick
    -- TODO: https://neovim.io/doc/user/lua.html#vim.uv
    vim.defer_fn(gameTick, tetris.game_speed)
    --print("Game tick scheduled") -- Debug message
  end

  -- Start the first tick
  gameTick()
end

-- TODO: NO
-- TODO: also, wtf is this tetris global business
tetris.run = function()
  -- TODO: NOT HERE
  tetris.namespace = vim.api.nvim_create_namespace("tetris")
  vim.api.nvim_set_hl(tetris.namespace, "TetrisBlock", { fg = "white", bg = "red" })
  vim.api.nvim_set_hl(tetris.namespace, "TetrisScore", { fg = "white", bg = "green" })

  -- Create UI
  tetris.ui.create_window()
  vim.api.nvim_win_set_hl_ns(tetris.ui.window.id, tetris.namespace)

  -- Cursor shenanigans
  vim.api.nvim_create_augroup("CustomCursorStyle", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = "CustomCursorStyle",
    buffer = tetris.ui.window.buffer, -- Apply only to your specific buffer
    callback = function()
      -- Set the cursor style to a bar for this buffer
      vim.opt_local.guicursor = "n-v-c:ver25" -- Bar cursor in Normal, Visual, Command-line Mode
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = "CustomCursorStyle",
    buffer = tetris.ui.window.buffer, -- Apply only to your specific buffer
    callback = function()
      -- Revert to the default cursor style
      vim.opt_local.guicursor = "" -- Resets to the global setting
    end,
  })

  -- Setup input (bindings)
  tetris.input.setup(tetris.ui.window.buffer)

  -- Start game (loop)
  tetris.loop()
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
