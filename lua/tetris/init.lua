---local async = require("plenary.async")
require("tetris.math")
local events = require("tetris.events")
local shapes = require("tetris.shapes")
local ui = require("tetris.ui")

local tetris = {
  game_speed = 160,
  input = require("tetris.input"),
  level_speed = 100,
  level_ticks = 0,
  should_close = false,
  --
  score = 0,
  score_max = 99999999,
  score_min = 0,
  --
  current_rotation = 0,
  current_shape = 1,
  current_x = 3,
  current_y = 4,
  --
  field_height = 22,
  field_width = 10,
  lock_delay = 0,
}

events.on("quit", function()
  tetris.should_close = true
  vim.api.nvim_win_close(ui.window, true)
end)

events.on("left", function()
  if DoesPieceFit(tetris.current_shape, tetris.current_rotation, tetris.current_x - 1, tetris.current_y) then
    tetris.current_x = tetris.current_x - 1
  end
end)

events.on("right", function()
  if DoesPieceFit(tetris.current_shape, tetris.current_rotation, tetris.current_x + 1, tetris.current_y) then
    tetris.current_x = tetris.current_x + 1
  end
end)

events.on("rotate", function()
  local newRotation = (tetris.current_rotation + 1) % 4

  if DoesPieceFit(tetris.current_shape, newRotation, tetris.current_x, tetris.current_y) then
    tetris.current_rotation = newRotation
  end
end)

local rotate = function(px, py, r)
  local pi
  local rotation = r % 4

  if rotation == 0 then
    -- 0 degrees rotation (no change)
    pi = py * 4 + px
  elseif rotation == 1 then
    -- 90 degrees rotation
    -- This translates the piece one position to the left and then rotates it down.
    pi = 12 + py - (px * 4)
  elseif rotation == 2 then
    -- 180 degrees rotation
    -- This is like flipping the piece upside down.
    pi = 15 - (py * 4) - px
  elseif rotation == 3 then
    -- 270 degrees rotation
    -- This translates the piece one position up and then rotates it to the right.
    pi = 3 - py + (px * 4)
  end

  return pi
end

function DoesPieceFit(nTetromino, nRotation, nPosX, nPosY)
  for px = 0, 3 do
    for py = 0, 3 do
      -- Get index into piece
      local pi = rotate(px, py, nRotation)

      -- Convert 1D index to 2D coordinates
      local row = math.floor(pi / 4) + 1
      local col = pi % 4 + 1

      -- Ensure row and column are within the bounds of the shape
      if row >= 1 and row <= #shapes[nTetromino] and col >= 1 and col <= #shapes[nTetromino][row] then
        local cell = shapes[nTetromino][row]:sub(col * 2 - 1, col * 2) -- Adjusted for double-width

        -- Get index into field, adjusting for Lua's 1-based indexing and double-width blocks
        local fi = (nPosY + py - 1) * tetris.nFieldWidth + (nPosX + px) * 2 -- Adjusted for double-width

        -- Collision check
        if cell ~= ".." and tetris.pField[fi] ~= 0 then
          return false -- Collision detected
        end
      end
    end
  end

  return true -- No collision
end

tetris.draw_game = function(buffer)
  if not vim.api.nvim_buf_is_valid(ui.buffer) then
    --print("Invalid buffer number. Exiting game loop.")
    return
  end

  -- -- Ensure each line is at least as long as the longest column index
  -- local lines = { " ", " " } -- Pre-filling lines with a space
  -- vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  ui.draw_layout()

  -- TODO: ew
  tetris.score = math.clamp(tetris.score + 10, tetris.score_min, tetris.score_max)

  vim.api.nvim_buf_set_extmark(ui.buffer, tetris.namespace, ui.pos_top[1] - 1, ui.pos_top[2], {
    virt_text = { { tostring(tetris.score), "TetrisTop" } },
    virt_text_pos = "overlay",
  })

  vim.api.nvim_buf_set_extmark(ui.buffer, tetris.namespace, ui.pos_score[1] - 1, ui.pos_score[2], {
    virt_text = { { tostring(tetris.score), "TetrisScore" } },
    virt_text_pos = "overlay",
  })

  vim.api.nvim_buf_set_extmark(ui.buffer, tetris.namespace, ui.pos_level[1] - 1, ui.pos_level[2], {
    virt_text = { { tostring(tetris.score), "TetrisLevel" } },
    virt_text_pos = "overlay",
  })

  vim.api.nvim_buf_set_extmark(ui.buffer, tetris.namespace, ui.pos_cursor[1] - 1, ui.pos_cursor[2], {
    virt_text = { { "█", "TetrisBlock" } },
    virt_text_pos = "overlay",
  })

  local next_shape = shapes[math.random(1, #shapes)]
  for i = 1, 2 do
    vim.api.nvim_buf_set_extmark(ui.buffer, tetris.namespace, ui.pos_next[1] + i - 1, ui.pos_next[2], {
      virt_text = { { next_shape[i], "TetrisBlockNext" } },
      virt_text_pos = "overlay",
    })
  end

  -- for y = 1, tetris.nFieldHeight do
  --   for x = 1, tetris.nFieldWidth do
  --     if x == 1 or x == tetris.nFieldWidth or y == tetris.nFieldHeight then
  --       tetris.pField[(y - 1) * tetris.nFieldWidth + x] = 9
  --     else
  --       tetris.pField[(y - 1) * tetris.nFieldWidth + x] = 0
  --     end
  --   end
  -- end
  --
  -- for px = 0, 3 do
  --   for py = 0, 3 do
  --     local pi = rotate(px, py, tetris.current_rotation)
  --
  --     local row = math.floor(pi / 4) + 1
  --     local col = pi % 4 + 1 -- Adjusted to get the block start index
  --
  --     if shapes[tetris.current_shape] and shapes[tetris.current_shape][row] then
  --       -- Extract two characters (a single block)
  --       local cell = shapes[tetris.current_shape][row]:sub((col - 1) * 2 + 1, col * 2)
  --
  --       if cell ~= ".." then
  --         local bufferRow = tetris.current_y + py
  --         local bufferCol = (tetris.current_x + px) * 2 -- Position in buffer considering double-width
  --
  --         vim.api.nvim_buf_set_extmark(buffer, tetris.namespace, bufferRow, bufferCol, {
  --           virt_text = { { "██", "TetrisBlock" } },
  --           virt_text_pos = "overlay",
  --         })
  --       end
  --     end
  --   end
  -- end
  --
  -- for px = 0, 3 do
  --   for py = 0, 3 do
  --     local pi = rotate(px, py, tetris.current_rotation)
  --
  --     local row = math.floor(pi / 4) + 1
  --     local col = pi % 4 + 1
  --
  --     if shapes[tetris.current_shape] then
  --       if shapes[tetris.current_shape][row] then
  --         if col <= #shapes[tetris.current_shape][row] then
  --           local cell = shapes[tetris.current_shape][row]:sub(col, col)
  --
  --           if cell ~= "." then
  --             local bufferRow = tetris.current_y + py
  --             local bufferCol = (tetris.current_x + px) * 2 -- Multiply by 2
  --             --local bufferCol = tetris.current_x + px
  --
  --             vim.api.nvim_buf_set_extmark(buffer, tetris.namespace, bufferRow, bufferCol, {
  --               virt_text = { { "██", "TetrisBlock" } },
  --               virt_text_pos = "overlay",
  --             })
  --           end
  --         end
  --       end
  --     end
  --   end
  -- end

  -- Fix (faux hide) cursor
  vim.api.nvim_win_set_cursor(ui.window, { ui.pos_cursor[1], ui.pos_cursor[2] })

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
      tetris.draw_game(ui.buffer)
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
  -- TODO: not tetris.namespace
  tetris.namespace = vim.api.nvim_create_namespace("tetris")
  vim.api.nvim_set_hl(tetris.namespace, "TetrisBlock", { fg = "white", bg = "red" })
  vim.api.nvim_set_hl(tetris.namespace, "TetrisBlockNext", { fg = "yellow" })
  vim.api.nvim_set_hl(tetris.namespace, "TetrisLevel", { fg = "blue" })
  vim.api.nvim_set_hl(tetris.namespace, "TetrisScore", { fg = "yellow" })
  vim.api.nvim_set_hl(tetris.namespace, "TetrisTop", { fg = "green" })

  -- Create UI
  ui.create_window()
  vim.api.nvim_win_set_hl_ns(ui.window, tetris.namespace)

  -- Cursor shenanigans
  vim.api.nvim_create_augroup("CustomCursorStyle", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = "CustomCursorStyle",
    buffer = ui.buffer, -- Apply only to your specific buffer
    callback = function()
      -- Set the cursor style to a bar for this buffer
      vim.opt_local.guicursor = "n-v-c:ver25" -- Bar cursor in Normal, Visual, Command-line Mode
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = "CustomCursorStyle",
    buffer = ui.buffer, -- Apply only to your specific buffer
    callback = function()
      -- Revert to the default cursor style
      vim.opt_local.guicursor = "" -- Resets to the global setting
    end,
  })

  -- Setup input (bindings)
  tetris.input.setup(ui.buffer)

  -- Start game (loop)
  tetris.loop()
end

tetris.setup = function(spec, opts)
  vim.api.nvim_create_user_command("Tetris", function(cmd)
    tetris.run()
  end, { nargs = 0 })
end

return tetris
