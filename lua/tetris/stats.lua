local stats = {}

stats.path = vim.fn.stdpath("data") .. "/tetris/stats.jsonl"

---@class TetrisStats
---@field clears number[] -- by lines at once, like line_points
---@field hard_drops number
---@field moves number
---@field pieces table<string, number> -- locked, by shape name
---@field rotations number
---@field started_at number

---@return TetrisStats
stats.new = function()
  return {
    clears = { 0, 0, 0, 0 },
    hard_drops = 0,
    moves = 0,
    pieces = {},
    rotations = 0,
    started_at = os.time(),
  }
end

---Appends the finished game to the log.
---@param state TetrisState
stats.save = function(state)
  local record = vim.tbl_extend("force", state.stats, {
    ended_at = os.time(),
    gravity = state.gravity,
    level = state.level,
    lines = state.lines_cleared,
    score = state.score,
  })

  vim.fn.mkdir(vim.fs.dirname(stats.path), "p")

  local file = assert(io.open(stats.path, "a"))
  file:write(vim.json.encode(record) .. "\n")
  file:close()
end

return stats
