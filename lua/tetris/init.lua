require("tetris.math")

local Display = require("tetris.display")
local Events = require("tetris.events")
local Input = require("tetris.input")
local config = require("tetris.config")
local shapes = require("tetris.shapes")

local tetris = {
  field_height = 22,
  field_width = 10,
  game_speed = 16,
  lock_delay = 0,
  score_max = 99999999,
  score_min = 0,
}

---@param options TetrisOptions
tetris.run = function(options)
  local is_paused = false
  local is_quitting = false
  local score = 0

  local display = Display:new()
  local events = Events:new()
  local input = Input:new()

  display:setup(shapes)
  input:setup(display.buffer, options.mappings, events)

  events:on("left", function()
    print("left")
  end)

  events:on("right", function()
    print("right")
  end)

  events:on("drop", function()
    print("drop")
  end)

  events:on("rotate", function()
    local rotation = (tetris.current_rotation + 1) % 4
    print("rotate", rotation)
  end)

  events:on("pause", function()
    is_paused = not is_paused
  end)

  events:on("quit", function()
    is_quitting = true
    display:close_window()
  end)

  local function tick()
    if is_quitting then
      return
    end

    if not is_paused then
      local status, err = pcall(function()
        -- TODO: game logic

        score = math.clamp(score + 10, tetris.score_min, tetris.score_max)
        local next_shape = shapes[math.random(1, #shapes)]

        display:draw_layout()

        display:draw_level(tostring(score))
        display:draw_score(tostring(score))
        display:draw_top(tostring(score))

        display:draw_next(next_shape)

        vim.api.nvim_win_set_cursor(display.window, { display.pos_cursor[1], display.pos_cursor[2] })
      end)

      if not status then
        vim.notify("Error in game loop: " .. err, vim.log.levels.ERROR)
        return
      end
    end

    vim.defer_fn(tick, tetris.game_speed)
  end

  tick()
end

---@param options TetrisOptions
tetris.setup = function(options)
  config.setup(options)

  vim.api.nvim_create_user_command("Tetris", function()
    tetris.run(config.options)
  end, { nargs = 0 })
end

return tetris
