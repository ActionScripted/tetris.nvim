---If you make me type "tetromino", I will be VERY unhappy.

---@class TetrisShape
---@field color string
---@field data string
---@field display string[]
---@field name string
---@field size number

---@type TetrisShape[]
local shapes = {
  {
    color = "cyan",
    data = "....XXXX........",
    display = {
      "        ",
      "████████",
      "        ",
      "        ",
    },
    name = "I",
    size = 4,
  },
  {
    color = "yellow",
    data = "XXXX",
    display = {
      "  ████  ",
      "  ████  ",
      "        ",
    },
    name = "O",
    size = 2,
  },
  {
    color = "blue",
    data = "X..XXX...",
    display = {
      "██    ",
      "██████",
      "      ",
    },
    name = "J",
    size = 3,
  },
  {
    color = "orange",
    data = "..XXXX...",
    display = {
      "    ██",
      "██████",
      "      ",
    },
    name = "L",
    size = 3,
  },
  {
    color = "purple",
    data = ".X.XXX...",
    display = {
      "  ██  ",
      "██████",
      "      ",
    },
    name = "T",
    size = 3,
  },
  {
    color = "green",
    data = ".XXXX....",
    display = {
      "  ████",
      "████  ",
      "      ",
    },
    name = "S",
    size = 3,
  },
  {
    color = "red",
    data = "XX..XX...",
    display = {
      "████  ",
      "  ████",
      "      ",
    },
    name = "Z",
    size = 3,
  },
}

return shapes
