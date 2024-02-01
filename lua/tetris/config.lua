local config = {}

---@class TetrisOptions
---NOTE: If you change these, update the README!
local defaults = {
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
    j = "down",
    k = "rotate",
    l = "right",
    p = "pause",
    q = "quit",
  },
}

---@type TetrisOptions
config.options = {}

function config.setup(options)
  config.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

config.setup()

return config
