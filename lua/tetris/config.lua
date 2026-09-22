local Config = {}
Config.__index = Config

---@class TetrisConstants
---@field blink_speed number
---@field field_empty string
---@field field_height number
---@field field_width number
---@field game_speed number
---@field gravity number[]
---@field line_points number[]
---@field lines_per_level number
---@field lock_delay number
---@field lock_resets_max number
---@field score_max number
---@field score_min number
---@field shape_size_max number
Config.constants = {
  blink_speed = 500, -- on for this long, off for this long
  field_empty = ".",
  field_height = 22,
  field_width = 10,
  game_speed = 16, -- 60fps, gamers.
  -- stylua: ignore
  gravity = { -- per-level gravity, classic values-ish
    48, 43, 38, 33, 28, 23, 18, 13, 8, 6, -- 0-9
    5, 5, 5, 4, 4, 4, 3, 3, 3,            -- 10-18
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2,         -- 19-28
    1,                                    -- 29+
  },
  line_points = { 100, 300, 500, 800 }, -- 1, 2, 3 or 4 lines at once
  lines_per_level = 10,
  lock_delay = 30,
  lock_resets_max = 15,
  score_max = 99999999,
  score_min = 0,
  shape_size_max = 4, -- largest NxN box any shape occupies
}

---@class TetrisOptions
---@field block string
---@field debug boolean
---@field mappings table<string, string>
Config.defaults = {
  block = "█",
  debug = false,
  mappings = {
    ["<Down>"] = "down",
    ["<Esc>"] = "quit",
    ["<Left>"] = "left",
    ["<LeftMouse>"] = "noop",
    ["<MiddleMouse>"] = "noop",
    ["<Mouse>"] = "noop",
    ["<Right>"] = "right",
    ["<RightMouse>"] = "noop",
    ["<Space>"] = "drop",
    ["<Up>"] = "rotate",
    h = "left",
    j = "rotate",
    k = "down",
    l = "right",
    p = "pause",
    q = "quit",
    r = "restart",
  },
}

---@class TetrisConfig
---@field constants TetrisConstants
---@field options TetrisOptions
function Config:new(opts)
  opts = opts or {}
  return setmetatable({
    options = vim.tbl_deep_extend("force", {}, Config.defaults, opts),
  }, self)
end

return Config
