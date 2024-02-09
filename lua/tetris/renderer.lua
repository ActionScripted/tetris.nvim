local utils = require("tetris.utils")

---@class TetrisRenderer
---@field block string
---@field buffer number
---@field extmarks table<string, number>
---@field guicursor string
---@field layout string[]
---@field namespace number
---@field pos_cursor number[]
---@field pos_field_end number[]
---@field pos_field_start number[]
---@field pos_level number[]
---@field pos_next number[]
---@field pos_score number[]
---@field pos_top number[]
---@field window number
---@field close_window fun(self)
---@field cursor_hide fun(self)
---@field cursor_reset fun(self)
---@field debug fun(self)
---@field draw_layout fun(self)
---@field draw_level fun(self, level: string)
---@field draw_next fun(self, next_shape: TetrisShape)
---@field draw_score fun(self, score: string)
local Renderer = {}

function Renderer:new()
  local instance = setmetatable({}, Renderer)

  instance.block = "X"
  instance.buffer = nil
  instance.extmarks = {}
  instance.guicursor = vim.o.guicursor
  instance.namespace = nil
  instance.window = nil

  instance.layout = utils.string_to_table([[
╭───────────────────────────────────╮
│ ▓ ▒ ░      TETRIS.NVIM      ░ ▒ ▓ │
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

  instance.pos_cursor = { 2, 4 }
  instance.pos_field_end = { 22, 22 }
  instance.pos_field_start = { 3, 3 }
  instance.pos_level = { 11, 27 }
  instance.pos_next = { 16, 31 }
  instance.pos_score = { 8, 27 }
  instance.pos_top = { 5, 27 }

  self.__index = self
  return instance
end

---@param name string
function Renderer:_del_extmark(name)
  if self.extmarks[name] then
    vim.api.nvim_buf_del_extmark(self.buffer, self.namespace, self.extmarks[name])
    self.extmarks[name] = nil
  end
end

---@param name string
---@param row number
---@param col number
---@param text string
---@param style string
function Renderer:_set_extmark(name, row, col, text, style)
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

function Renderer:close_window()
  if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
    vim.api.nvim_buf_delete(self.buffer, { force = true })
  end

  if self.window and vim.api.nvim_win_is_valid(self.window) then
    vim.api.nvim_win_close(self.window, true)
  end

  self.buffer = nil
  self.window = nil
end

function Renderer:cursor_hide()
  vim.api.nvim_win_set_cursor(self.window, { self.pos_cursor[1], self.pos_cursor[2] })
  vim.o.guicursor = "n-v-c-i-ci-ve-r-cr-o:ver25"
end

function Renderer:cursor_reset()
  vim.o.guicursor = self.guicursor
end

---TODO: lower z-index of debug extmarks
function Renderer:debug()
  local extmarks_debug = 1

  local fstart_x = self.pos_field_start[1]
  local fstart_y = self.pos_field_start[2]
  local fend_x = self.pos_field_end[1]
  local fend_y = self.pos_field_end[2]

  for x = fstart_x, fend_x do
    for y = fstart_y, fend_y do
      extmarks_debug = extmarks_debug + 1
      self:_set_extmark("c1_" .. x .. y, x, y, "X", "TetrisShape-red")
    end
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(self.buffer, self.namespace, 0, -1, { details = false })
  self:_set_extmark("extmarks", 1, 3, tostring(#extmarks) .. "(" .. extmarks_debug .. ")", "TetrisShape-red")
end

---@param shape TetrisShape
---@param x number
---@param y number
---@param rotation number
function Renderer:draw_shape(shape, x, y, rotation)
  local x_trans = x + self.pos_field_start[1]
  local y_trans = y + self.pos_field_start[2]

  for sy = 0, shape.size - 1 do
    for sx = 0, shape.size - 1 do
      local index = utils.rotated_index(sx, sy, shape.size, rotation)
      local char = shape.data:sub(index + 1, index + 1)

      if char == "X" then
        local out = self.block .. self.block
        self:_set_extmark("c" .. index, y_trans + sy, (x_trans + sx) * 2, out, "TetrisShape-" .. shape.color)
      else
        self:_del_extmark("c" .. index)
      end
    end
  end
end

function Renderer:draw_layout()
  vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, self.layout)
end

---@param level string
function Renderer:draw_level(level)
  self:_set_extmark("level", self.pos_level[1] - 1, self.pos_level[2], level, "TetrisLevel")
end

---@param score string
function Renderer:draw_score(score)
  self:_set_extmark("score", self.pos_score[1] - 1, self.pos_score[2], score, "TetrisScore")
end

---@param top string
function Renderer:draw_top(top)
  self:_set_extmark("top", self.pos_top[1] - 1, self.pos_top[2], top, "TetrisTop")
end

---@param next_shape TetrisShape
function Renderer:draw_next(next_shape)
  local hl = "TetrisShape-" .. next_shape.color
  self:_set_extmark("next1", self.pos_next[1] - 1, self.pos_next[2], next_shape.display[1], hl)
  self:_set_extmark("next2", self.pos_next[1], self.pos_next[2], next_shape.display[2], hl)
end

---@param shapes TetrisShape[]
function Renderer:setup(config, shapes)
  local height = #self.layout
  local width = vim.fn.strdisplaywidth(self.layout[1])

  self.block = config.options.block

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

  vim.api.nvim_set_hl(self.namespace, "TetrisLevel", { fg = "white", bold = true })
  vim.api.nvim_set_hl(self.namespace, "TetrisScore", { fg = "white", bold = true })
  vim.api.nvim_set_hl(self.namespace, "TetrisTop", { fg = "white", bold = true })

  for _, shape in ipairs(shapes) do
    vim.api.nvim_set_hl(self.namespace, "TetrisShape-" .. shape.color, { fg = shape.color })
  end
end

return Renderer
