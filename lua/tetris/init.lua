require("tetris.math")

local Config = require("tetris.config")
local Controller = require("tetris.controller")
local Events = require("tetris.events")
local Input = require("tetris.input")
local Renderer = require("tetris.renderer")
local State = require("tetris.state")
local shapes = require("tetris.shapes")
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
  local state = State:new()

  ---"but in a game...a common trick", Lua docs
  math.randomseed(os.time())

  ---Don't you DARE sort these, me.
  ---Don't you DARE sort these, me.
  state:setup(config.constants)
  input:map_actions(renderer.buffer, config.options.mappings, events)

  ---TODO: move up; apply patterns to other classes
  local controller = Controller:new({
    constants = config.constants,
    renderer = renderer,
    state = state,
  })

  -- stylua: ignore start
  events:on("down",   function() controller:shape_move_down()  end)
  events:on("drop",   function() controller:shape_drop()       end)
  events:on("left",   function() controller:shape_move_left()  end)
  events:on("pause",  function() controller:pause()            end)
  events:on("quit",   function() controller:quit()             end)
  events:on("right",  function() controller:shape_move_right() end)
  events:on("rotate", function() controller:shape_rotate()     end)
  -- stylua: ignore end

  --- TODO: move to controller
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
              config.constants,
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

        local next_shape = shapes[math.random(1, #shapes)]
        renderer:draw(config, state, next_shape)
      end)

      if not status then
        vim.notify("Error in game loop: " .. err, vim.log.levels.ERROR)
        renderer:cursor_reset()
        return
      end
    end

    vim.defer_fn(tick, config.constants.game_speed)
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
