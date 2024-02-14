require("tetris.math")

local Controller = require("tetris.controller")
local Events = require("tetris.events")
local Input = require("tetris.input")
local Renderer = require("tetris.renderer")
local State = require("tetris.state")
local config = require("tetris.config")
local shapes = require("tetris.shapes")
local utils = require("tetris.utils")

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
  state:setup(constants)
  renderer:setup(config, shapes)
  input:map_actions(renderer.buffer, options.mappings, events)

  ---TODO: move up; apply patterns to other classes
  local controller = Controller:new({
    constants = constants,
    renderer = renderer,
    state = state,
  })

  events:on("down", function()
    controller:shape_move_down()
  end)

  events:on("drop", function()
    controller:shape_drop()
  end)

  events:on("left", function()
    controller:shape_move_left()
  end)

  events:on("pause", function()
    controller:pause()
  end)

  events:on("quit", function()
    controller:quit()
  end)

  events:on("right", function()
    controller:shape_move_right()
  end)

  events:on("rotate", function()
    controller:shape_rotate()
  end)

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
          ---TODO: DRY-up this along with the events; consolidate...somewhere
          if
            not utils.can_move(
              constants,
              state,
              state.current_shape,
              state.current_x,
              state.current_y + 1,
              state.current_rotation
            )
          then
            controller:shape_lock()
            state.current_shape = shapes[math.random(1, #shapes)]
          else
            state.current_y = state.current_y + 1
          end
        end

        state.score = math.clamp(state.score + 10, constants.score_min, constants.score_max)
        local next_shape = shapes[math.random(1, #shapes)]

        renderer:draw_layout()
        renderer:cursor_hide()

        renderer:draw_field(constants, state)
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
