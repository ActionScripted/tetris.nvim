require("tetris.math")

local Events = require("tetris.events")
local Input = require("tetris.input")
local Renderer = require("tetris.renderer")
local config = require("tetris.config")
local shapes = require("tetris.shapes")

local tetris = {
  field_height = 22,
  field_width = 10,
  game_speed = 16, -- 60fps, gamers.
  lock_delay = 500,
  score_max = 99999999,
  score_min = 0,
}

---@param options TetrisOptions
tetris.run = function(options)
  local current_rotation = 0
  local current_shape = nil
  local current_x = 0
  local current_y = 0

  local drop_speed = 48
  local is_paused = false
  local is_quitting = false
  local score = 0
  local tick_count = 0

  local renderer = Renderer:new()
  local events = Events:new()
  local input = Input:new()

  renderer:setup(shapes)
  input:setup(renderer.buffer, options.mappings, events)

  events:on("left", function()
    current_x = current_x - 1
  end)

  events:on("right", function()
    current_x = current_x + 1
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
    renderer:close_window()
  end)

  local function tick()
    if is_quitting then
      renderer:cursor_reset()
      return
    end

    if not is_paused then
      local status, err = pcall(function()
        tick_count = tick_count + 1

        if not current_shape then
          current_shape = shapes[math.random(1, #shapes)]
        end

        if tick_count % drop_speed == 0 then
          current_y = current_y + 1
        end

        score = math.clamp(score + 10, tetris.score_min, tetris.score_max)
        local next_shape = shapes[math.random(1, #shapes)]

        renderer:draw_layout()
        renderer:cursor_hide()

        renderer:draw_shape(current_shape, current_x, current_y, current_rotation)

        renderer:draw_level(tostring(score))
        renderer:draw_next(next_shape)
        renderer:draw_score(tostring(score))
        renderer:draw_top(tostring(score))

        if options.debug then
          renderer:debug()
        end
      end)

      if not status then
        vim.notify("Error in game loop: " .. err, vim.log.levels.ERROR)
        renderer:cursor_reset()
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
