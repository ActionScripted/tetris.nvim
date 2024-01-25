---Layouts (views) for the game.
local layouts = {}

---Convert a string to a table of strings.
---For drawing to buffers we need a table of strings, where each string
---is a line. But it's not fun to define layouts as tables.
---@param layout string
---@return table
local string_to_table = function(layout)
  local lines = {}
  for s in layout:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

---Main layout.
---@return table
layouts.main = function()
  local layout = [[
╭───────────────────────────────────╮
│            TETRIS.NVIM            │
├────────────────────────┬──────────┤
│                        │ TOP      │
│                        │          │
│                        ├──────────┤
│                        │ SCORE    │
│                        │          │
│                        ├──────────┤
│                        │ LEVEL    │
│                        │          │
│                        ├──────────┤
│                        │ NEXT     │
│                        │ ╭──────╮ │
│                        │ │      │ │
│                        │ │      │ │
│                        │ │      │ │
│                        │ │      │ │
│                        │ ╰──────╯ │
│                        │          │
│                        │          │
│                        │          │
╰────────────────────────┴──────────╯
]]
  return string_to_table(layout)
end

return layouts
