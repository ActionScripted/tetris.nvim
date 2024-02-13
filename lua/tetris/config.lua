---@class TetrisConfig
local config = {}

---@class TetrisConstants
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
---NOTE: If you change these, update the README!
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

---@type TetrisOptions
config.options = {}

---@param opts TetrisOptions
function config.setup(opts)
  config.options = vim.tbl_deep_extend("force", {}, options, opts or {})
end

return config
