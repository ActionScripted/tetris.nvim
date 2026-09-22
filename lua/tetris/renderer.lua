local utils = require("tetris.utils")

local Renderer = {}
Renderer.__index = Renderer

Renderer.layout = utils.string_to_table([[
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
│                    ├──────────────┤
│                    │              │
╰────────────────────┴──────────────╯
]])

Renderer.pos_cursor = { 2, 4 }
Renderer.pos_field_end = { 22, 22 }
Renderer.pos_field_start = { 3, 3 }
Renderer.pos_level = { 11, 27 }
Renderer.pos_next = { 16, 31 }
Renderer.pos_score = { 8, 27 }
Renderer.pos_status = { 22, 27 }
Renderer.pos_top = { 5, 27 }

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
---@field pos_status number[]
---@field pos_top number[]
---@field window number
---
---@field _del_extmark fun(self, name: string)
---@field _set_extmark fun(self, name: string, row: number, col: number, text: string, style: string)
---@field clear_shape fun(self, constants: TetrisConstants)
---@field close_window fun(self)
---@field cursor_hide fun(self)
---@field cursor_reset fun(self)
---@field debug fun(self)
---@field draw fun(self, config: TetrisConfig, state: TetrisState)
---@field draw_field fun(self, constants: TetrisConstants, state: TetrisState)
---@field draw_layout fun(self)
---@field draw_level fun(self, level: string)
---@field draw_next fun(self, next_shape: TetrisShape)
---@field draw_overlay fun(self, constants: TetrisConstants, state: TetrisState)
---@field draw_score fun(self, score: string)
---@field draw_shape fun(self, shape: TetrisShape, x: number, y: number, rotation: number)
---@field draw_top fun(self, top: string)
---@field new fun(options: table, shapes: table): TetrisRenderer
---
---@param options TetrisOptions
---@param shapes TetrisShape[]
function Renderer:new(options, shapes)
  local self = setmetatable({}, Renderer)

  local win_height = #self.layout
  local win_width = vim.fn.strdisplaywidth(self.layout[1])

  self.block = options.block
  self.buffer = vim.api.nvim_create_buf(false, true)
  self.extmarks = {}
  self.guicursor = vim.o.guicursor
  self.namespace = vim.api.nvim_create_namespace("tetris")
  self.window = vim.api.nvim_open_win(self.buffer, true, {
    col = math.floor((vim.o.columns - win_width) / 2),
    height = win_height,
    relative = "editor",
    row = math.floor(((vim.o.lines - win_height) / 2) - 1),
    style = "minimal",
    width = win_width,
  })

  vim.api.nvim_win_set_hl_ns(self.window, self.namespace)

  vim.api.nvim_set_hl(self.namespace, "TetrisLevel", { fg = "white", bold = true })
  vim.api.nvim_set_hl(self.namespace, "TetrisScore", { fg = "white", bold = true })
  vim.api.nvim_set_hl(self.namespace, "TetrisStatus", { fg = "white", bold = true })
  vim.api.nvim_set_hl(self.namespace, "TetrisTop", { fg = "white", bold = true })

  for _, shape in ipairs(shapes) do
    vim.api.nvim_set_hl(self.namespace, "TetrisShape-" .. shape.color, { fg = shape.color })
  end

  self:draw_layout()
  vim.o.guicursor = "n-v-c-i-ci-ve-r-cr-o:ver25"

  return self
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

---@param constants TetrisConstants
function Renderer:clear_shape(constants)
  for sy = 0, constants.shape_size_max - 1 do
    for sx = 0, constants.shape_size_max - 1 do
      self:_del_extmark("c" .. sy .. sx)
    end
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

---@param config TetrisConfig
---@param state TetrisState
function Renderer:draw(config, state)
  self:cursor_hide()

  self:draw_field(config.constants, state)
  self:clear_shape(config.constants)

  if state.current_shape then
    self:draw_shape(state.current_shape, state.current_x, state.current_y, state.current_rotation)
  end

  self:draw_level(tostring(state.level))

  if state.next_shape then
    self:draw_next(state.next_shape)
  end

  self:draw_overlay(config.constants, state)
  self:draw_score(tostring(state.score))
  self:draw_top(tostring(state.top_score))

  if config.options.debug then
    self:debug()
  end
end

---@param constants TetrisConstants
---@param state TetrisState
function Renderer:draw_field(constants, state)
  for y = 0, constants.field_height - 1 do
    for x = 0, constants.field_width - 1 do
      local field_index = (constants.field_width * y) + x

      if state.field[field_index] ~= constants.field_empty then
        self:_set_extmark(
          "field" .. x .. y,
          y + self.pos_field_start[2],
          x * 2 + self.pos_field_start[1],
          self.block .. self.block,
          "TetrisShape-" .. state.field[field_index]
        )
      else
        self:_del_extmark("field" .. x .. y)
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

---@param next_shape TetrisShape
function Renderer:draw_next(next_shape)
  local hl = "TetrisShape-" .. next_shape.color
  self:_set_extmark("next1", self.pos_next[1] - 1, self.pos_next[2], next_shape.display[1], hl)
  self:_set_extmark("next2", self.pos_next[1], self.pos_next[2], next_shape.display[2], hl)
end

---Game over and paused share one slot under the NEXT box, and only one of them
---shows at a time. The blink runs off the clock rather than the tick counter,
---which stops dead the moment the game is paused or over.
---@param constants TetrisConstants
---@param state TetrisState
function Renderer:draw_overlay(constants, state)
  local text

  if state.is_game_over then
    text = "GAME OVER"
  elseif state.is_paused then
    text = "PAUSED"
  end

  if not text or vim.uv.now() % (constants.blink_speed * 2) >= constants.blink_speed then
    self:_del_extmark("status")
    return
  end

  self:_set_extmark("status", self.pos_status[1], self.pos_status[2], text, "TetrisStatus")
end

---@param score string
function Renderer:draw_score(score)
  self:_set_extmark("score", self.pos_score[1] - 1, self.pos_score[2], score, "TetrisScore")
end

---@param shape TetrisShape
---@param x number
---@param y number
---@param rotation number
function Renderer:draw_shape(shape, x, y, rotation)
  local field_x = x * 2 + self.pos_field_start[1]
  local field_y = y + self.pos_field_start[2]

  for sy = 0, shape.size - 1 do
    for sx = 0, shape.size - 1 do
      local index = utils.rotated_index(sx, sy, shape.size, rotation)
      local char = shape.data:sub(index + 1, index + 1)

      if char == "X" then
        self:_set_extmark(
          "c" .. sy .. sx,
          field_y + sy,
          field_x + (sx * 2),
          self.block .. self.block,
          "TetrisShape-" .. shape.color
        )
      end
    end
  end
end

---@param top string
function Renderer:draw_top(top)
  self:_set_extmark("top", self.pos_top[1] - 1, self.pos_top[2], top, "TetrisTop")
end

return Renderer
