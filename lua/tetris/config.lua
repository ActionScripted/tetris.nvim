---@class TetrisConfig
---@field constants TetrisConstants
---@field options TetrisOptions
local config = {}

---@class TetrisConstants
---@field field_empty string
---@field field_height number
---@field field_width number
---@field game_speed number
---@field lock_delay number
---@field score_max number
---@field score_min number
config.constants = {
  field_empty = ".",
  field_height = 22,
  field_width = 10,
  game_speed = 16, -- 60fps, gamers.
  lock_delay = 500,
  score_max = 99999999,
  score_min = 0,
}

---@class TetrisOptions
---
---NOTE: If you change these, update the README!
---NOTE: If you change these, update the README!
---
---@field block string
---@field debug boolean
---@field mappings table<string, string>
local options = {
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
  },
}

---@param opts TetrisOptions
function config.setup(opts)
  config.options = vim.tbl_deep_extend("force", {}, options, opts or {})
end

return config
