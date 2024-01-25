local layouts = {
  cache = {},
}

---Convert a string to a table of strings for writing to buffers.
---@param layout string
---@return table
local string_to_table = function(layout)
  local lines = {}
  for s in layout:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

---@return table
layouts.main = function()
  if layouts.cache.main then
    return layouts.cache.main
  end

  layouts.cache.main = string_to_table([[
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
]])

  return layouts.cache.main
end

return layouts
