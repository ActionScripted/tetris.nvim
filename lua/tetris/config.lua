local Config = {}
Config.__index = Config

---@class TetrisConstants
---@field blink_speed number
---@field drop_speed_initial number
---@field drop_speed_min number
---@field field_empty string
---@field field_height number
---@field field_width number
---@field game_speed number
---@field line_points number[]
---@field lines_per_level number
---@field lock_delay number
---@field score_max number
---@field score_min number
---@field shape_size_max number
Config.constants = {
  blink_speed = 500, -- on for this long, off for this long
  drop_speed_initial = 48,
  drop_speed_min = 5,
  field_empty = ".",
  field_height = 22,
  field_width = 10,
  game_speed = 16, -- 60fps, gamers.
  line_points = { 100, 300, 500, 800 }, -- 1, 2, 3 or 4 lines at once
  lines_per_level = 10,
  lock_delay = 500,
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
