require("tetris.math")

local Events = require("tetris.events")
local Input = require("tetris.input")
local Renderer = require("tetris.renderer")
local State = require("tetris.state")
local config = require("tetris.config")
local shapes = require("tetris.shapes")

---@class Tetris
---@field run fun(constants: TetrisConstants, options: TetrisOptions)
---@field setup fun(opts: TetrisOptions)
local tetris = {}

---@param constants TetrisConstants
---@param options TetrisOptions
tetris.run = function(constants, options)
  local state = State:new()
  local renderer = Renderer:new()
  local events = Events:new()
  local input = Input:new()

  ---"but in a game...a common trick", Lua docs
  math.randomseed(os.time())

  ---Don't you DARE sort these, me.
  ---Don't you DARE sort these, me.
  state:setup()
  renderer:setup(config, shapes)
  events:setup(state, renderer)
  input:setup(renderer.buffer, options.mappings, events)

  local function tick()
    if state.is_quitting then
      renderer:cursor_reset()
      return
    end

    if not state.is_paused then
      local status, err = pcall(function()
        state.tick_count = state.tick_count + 1

        if not state.current_shape then
          state.current_shape = shapes[math.random(1, #shapes)]
        end

        if state.tick_count % state.drop_speed == 0 then
          state.current_y = state.current_y + 1
        end

        state.score = math.clamp(state.score + 10, constants.score_min, constants.score_max)
        local next_shape = shapes[math.random(1, #shapes)]

        renderer:draw_layout()
        renderer:cursor_hide()

        renderer:draw_shape(state.current_shape, state.current_x, state.current_y, state.current_rotation)

        renderer:draw_level(tostring(state.score))
        renderer:draw_next(next_shape)
        renderer:draw_score(tostring(state.score))
        renderer:draw_top(tostring(state.score))

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

    vim.defer_fn(tick, constants.game_speed)
  end

  tick()
end

---@param opts TetrisOptions
tetris.setup = function(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("Tetris", function()
    tetris.run(config.constants, config.options)
  end, { nargs = 0 })
end

return tetris
