local utils = require("tetris.utils")

local Display = {}

function Display:new()
  local instance = setmetatable({}, Display)

  instance.buffer = nil
  instance.namespace = nil
  instance.extmarks = {}
  instance.window = nil

  instance.layout = utils.string_to_table([[
╭───────────────────────────────────╮
│            TETRIS.NVIM            │
├────────────────────┬──────────────┤
│                    │ TOP          │
│                    │              │
│                    ├──────────────┤
│                    │ SCORE        │
│                    │              │
│                    ├──────────────┤
│                    │ LEVEL        │
│                    │              │
│                    ├──────────────┤
│                    │ NEXT         │
│                    │ ╭──────────╮ │
│                    │ │          │ │
│                    │ │          │ │
│                    │ │          │ │
│                    │ │          │ │
│                    │ ╰──────────╯ │
│                    │              │
│                    │              │
│                    │              │
│                    │              │
╰────────────────────┴──────────────╯
]])

  instance.pos_cursor = { 2, 37 }
  instance.pos_level = { 11, 27 }
  instance.pos_next = { 16, 31 }
  instance.pos_score = { 8, 27 }
  instance.pos_top = { 5, 27 }

  self.__index = self
  return instance
end

function Display:_set_extmark(name, row, col, text, style)
  if not self.extmarks[name] then
    self.extmarks[name] = vim.api.nvim_buf_set_extmark(self.buffer, self.namespace, row, col, {
      virt_text = { { tostring(text), style } },
      virt_text_pos = "overlay",
    })
  else
    vim.api.nvim_buf_set_extmark(self.buffer, self.namespace, row, col, {
      id = self.extmarks[name],
      virt_text = { { tostring(text), style } },
      virt_text_pos = "overlay",
    })
  end
end

function Display:close_window()
  if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
    vim.api.nvim_buf_delete(self.buffer, { force = true })
  end

  if self.window and vim.api.nvim_win_is_valid(self.window) then
    vim.api.nvim_win_close(self.window, true)
  end

  self.buffer = nil
  self.window = nil
end

function Display:debug()
  local extmarks = vim.api.nvim_buf_get_extmarks(self.buffer, self.namespace, 0, -1, { details = false })
  print(#extmarks)
end

function Display:draw_layout()
  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, self.layout)
end

function Display:draw_level(level)
  self:_set_extmark("level", self.pos_level[1] - 1, self.pos_level[2], level, "TetrisLevel")
end

function Display:draw_score(score)
  self:_set_extmark("score", self.pos_score[1] - 1, self.pos_score[2], score, "TetrisScore")
end

function Display:draw_top(top)
  self:_set_extmark("top", self.pos_top[1] - 1, self.pos_top[2], top, "TetrisTop")
end

function Display:draw_next(next_shape)
  local hl = "TetrisShape-" .. next_shape.color
  self:_set_extmark("next1", self.pos_next[1] - 1, self.pos_next[2], next_shape.display[1], hl)
  self:_set_extmark("next2", self.pos_next[1], self.pos_next[2], next_shape.display[2], hl)
end

function Display:setup(shapes)
  local height = #self.layout
  local width = vim.fn.strdisplaywidth(self.layout[1])

  self.buffer = vim.api.nvim_create_buf(false, true)
  self.namespace = vim.api.nvim_create_namespace("tetris")
  self.window = vim.api.nvim_open_win(self.buffer, true, {
    col = math.floor((vim.o.columns - width) / 2),
    height = height,
    relative = "editor",
    row = math.floor(((vim.o.lines - height) / 2) - 1),
    style = "minimal",
    width = width,
  })

  vim.api.nvim_win_set_hl_ns(self.window, self.namespace)

  vim.api.nvim_set_hl(self.namespace, "TetrisLevel", { fg = "blue" })
  vim.api.nvim_set_hl(self.namespace, "TetrisScore", { fg = "yellow" })
  vim.api.nvim_set_hl(self.namespace, "TetrisTop", { fg = "green" })

  for _, shape in ipairs(shapes) do
    vim.api.nvim_set_hl(self.namespace, "TetrisShape-" .. shape.color, { fg = shape.color })
  end
end

return Display
