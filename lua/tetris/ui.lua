local ui = {
  buffer = nil,
  window = nil,
}

---Necessary for writing to buffers.
---@param layout string
---@return table
local string_to_table = function(layout)
  local lines = {}
  for s in layout:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

ui.layout = string_to_table([[
╭───────────────────────────────────────╮
│              TETRIS.NVIM              │
├────────────────────────┬──────────────┤
│                        │ TOP          │
│                        │              │
│                        ├──────────────┤
│                        │ SCORE        │
│                        │              │
│                        ├──────────────┤
│                        │ LEVEL        │
│                        │              │
│                        ├──────────────┤
│                        │ NEXT         │
│                        │ ╭──────────╮ │
│                        │ │          │ │
│                        │ │          │ │
│                        │ │          │ │
│                        │ │          │ │
│                        │ ╰──────────╯ │
│                        │              │
│                        │              │
│                        │              │
╰────────────────────────┴──────────────╯
]])

ui.pos_cursor = { 2, 41 }
ui.pos_level = { 11, 31 }
ui.pos_next = { 15, 35 }
ui.pos_score = { 8, 31 }
ui.pos_top = { 5, 31 }

ui.draw_layout = function()
  vim.api.nvim_buf_set_lines(ui.buffer, 0, -1, false, ui.layout)
end

ui.create_window = function()
  local height = #ui.layout
  local width = vim.fn.strdisplaywidth(ui.layout[1])

  ui.buffer = vim.api.nvim_create_buf(false, true)
  ui.window = vim.api.nvim_open_win(ui.buffer, true, {
    col = math.floor((vim.o.columns - width) / 2),
    height = height,
    relative = "editor",
    row = math.floor(((vim.o.lines - height) / 2) - 1),
    style = "minimal",
    width = width,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = ui.buffer,
    callback = function()
      pcall(vim.api.nvim_buf_delete, ui.buffer, { force = true })
      pcall(vim.api.nvim_win_close, ui.window, true)
    end,
  })

  ui.draw_layout()
end

return ui
