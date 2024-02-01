---If you make me type "tetromino", I will be VERY unhappy.

---@class TetrisShape
---@field color string
---@field data string
---@field display string[]
---@field name string

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
  },
  {
    color = "yellow",
    data = ".XX..XX.....",
    display = {
      "  ████  ",
      "  ████  ",
      "        ",
    },
    name = "O",
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
  },
}

return shapes
