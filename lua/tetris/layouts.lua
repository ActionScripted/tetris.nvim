local layouts = {}

local string_to_table = function(layout)
  local lines = {}
  for s in layout:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

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
