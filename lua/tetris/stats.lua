local stats = {}

stats.path = vim.fn.stdpath("data") .. "/tetris/stats.jsonl"

---@class TetrisStats
---@field clears number[]
---@field hard_drops number
---@field moves number
---@field pieces table<string, number>
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

  if stats._top_score then
    stats._top_score = math.max(stats._top_score, state.score)
  end
end

---@return number
stats.top_score = function()
  if not stats._top_score then
    stats._top_score = 0

    local file = io.open(stats.path, "r")
    if file then
      for line in file:lines() do
        local score = tonumber(line:match('"score":(%d+)'))
        stats._top_score = math.max(stats._top_score, score or 0)
      end
      file:close()
    end
  end

  return stats._top_score
end

return stats
