require("tetris.math")

local Config = require("tetris.config")
local Controller = require("tetris.controller")
local Events = require("tetris.events")
local Input = require("tetris.input")
local Renderer = require("tetris.renderer")
local State = require("tetris.state")
local shapes = require("tetris.shapes")
local stats = require("tetris.stats")
local utils = require("tetris.utils")

---@class Tetris
---@field run fun(config: TetrisConfig)
---@field setup fun(opts: TetrisOptions)
local tetris = {}

---@param config TetrisConfig
tetris.run = function(config)
  local events = Events:new()
  local input = Input:new()
  local renderer = Renderer:new(config.options, shapes)
  local state = State:new(config.constants)

  ---"but in a game...a common trick", Lua docs
  math.randomseed(os.time())

  ---Don't you DARE sort these, me.
  ---Don't you DARE sort these, me.
  input:map_actions(renderer.buffer, config.options.mappings, events)

  ---TODO: move up; apply patterns to other classes
  local controller = Controller:new({
    constants = config.constants,
    renderer = renderer,
    state = state,
  })

  -- stylua: ignore start
  events:on("down",    function() controller:shape_move_down()  end)
  events:on("drop",    function() controller:shape_drop()       end)
  events:on("left",    function() controller:shape_move_left()  end)
  events:on("pause",   function() controller:pause()            end)
  events:on("quit",    function() controller:quit()             end)
  events:on("restart", function() controller:restart()          end)
  events:on("right",   function() controller:shape_move_right() end)
  events:on("rotate",  function() controller:shape_rotate()     end)
  -- stylua: ignore end

  --- TODO: move to controller
  local function tick()
    if state.is_quitting then
      renderer:cursor_reset()
      return
    end

    ---Scheduled up front so one bad frame can't take the loop down with it.
    vim.defer_fn(tick, config.constants.game_speed)

    local ok, err = pcall(function()
      if not state.is_paused and not state.is_game_over then
        if not state.current_shape then
          state.current_shape = state.next_shape or utils.random_shape(shapes)
          state.next_shape = utils.random_shape(shapes)

          state.current_rotation = 0
          state.current_x = math.floor((config.constants.field_width - state.current_shape.size) / 2)
          state.current_y = 0
          state.gravity_ticks = 0
          state.lock_resets = 0
          state.lock_ticks = 0
          state.lowest_y = 0

          ---Nowhere to put the new shape? That's the game.
          state.is_game_over = not utils.can_move(
            config.constants,
            state,
            state.current_shape,
            state.current_x,
            state.current_y,
            state.current_rotation
          )

          if state.is_game_over then
            stats.save(state)
          end
        end

        if not state.is_game_over then
          local is_grounded = not utils.can_move(
            config.constants,
            state,
            state.current_shape,
            state.current_x,
            state.current_y + 1,
            state.current_rotation
          )

          if is_grounded then
            state.lock_ticks = state.lock_ticks + 1
            if
              state.lock_ticks >= config.constants.lock_delay
              or state.lock_resets >= config.constants.lock_resets_max
            then
              controller:shape_lock()
            end
          else
            state.lock_ticks = 0
            state.gravity_ticks = state.gravity_ticks + 1
            if state.gravity_ticks >= state.gravity then
              state.gravity_ticks = 0
              controller:attempt_change("down")
            end
          end
        end
      end

      renderer:draw(config, state)
    end)

    if not ok then
      vim.notify("Error in game loop: " .. err, vim.log.levels.ERROR)
      state.is_quitting = true
      renderer:cursor_reset()
    end
  end

  tick()
end

---@param opts TetrisOptions
tetris.setup = function(opts)
  local config = Config:new(opts)

  vim.api.nvim_create_user_command("Tetris", function()
    tetris.run(config)
  end, { nargs = 0 })
end

return tetris
