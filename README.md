# 🧱 tetris.nvim

Pure Lua tetris game for Neovim!

![tetris.nvim](https://raw.githubusercontent.com/ActionScripted/tetris.nvim/main/media/social-1280x640.jpg)

## ✅ Requirements

Neovim 0.10+ (due to `vim.uv`)

## 📦 Installation

Using lazy.nvim:

```lua
{
  "ActionScripted/tetris.nvim",
  cmd = { "Tetris" },
  keys = { { "<leader>T", "<cmd>Tetris<cr>", desc = "Tetris" } },
  opts = {
    -- your awesome configuration here
  },
}
```

## ⚙️ Configuration

These are the defaults:

```lua
{
  block = "█",
  debug = false,
  mappings = {
    ["<Down>"] = "down",
    ["<Esc>"] = "quit",
    ["<Left>"] = "left",
    ["<LeftMouse>"] = "noop",
    ["<MiddleMouse>"] = "noop",
    ["<Mouse>"] = "noop",
    ["<Right>"] = "right",
    ["<RightMouse>"] = "noop",
    ["<Space>"] = "drop",
    ["<Up>"] = "rotate",
    h = "left",
    j = "down",
    k = "rotate",
    l = "right",
    p = "pause",
    q = "quit",
  },
}
```

You can override these or add your own, for example:

```lua
{
  -- Hey, get weird:
  -- https://symbl.cc/en/unicode/table/#block-elements
  block = "╋",
  mappings = {
    ["<Space>"] = "noop",
    a = "left",
    d = "right",
    s = "down",
    w = "rotate",
  },
}
```

Available events:

| Event  | Description      |
| ------ | ---------------- |
| down   | Move piece down  |
| drop   | Drop piece       |
| left   | Move piece left  |
| noop   | Do nothing       |
| pause  | Pause game       |
| quit   | Quit game        |
| right  | Move piece right |
| rotate | Rotate piece     |

## 🚀 Usage

To start the game run `:Tetris` or `<leader>T` if you have the lazy.nvim config from above.

## 🛠️ Development

We're trying to follow the Super Rotation System (SRS) that dictates how pieces spawn and rotate. This also includes stuff like wall kicks, infinity and other tetromino-related terminology:

- <https://tetris.wiki/Super_Rotation_System>
- <https://harddrop.com/wiki/SRS>

Leaning on [Lua Language Server](https://luals.github.io/) for annotations and docs.

## 📚 Resources

- **Inspiration: <https://www.youtube.com/watch?v=8OK8_tHeCIA>**
    - <https://github.com/OneLoneCoder/Javidx9/blob/master/SimplyCode/OneLoneCoder_Tetris.cpp>
    - Big shout out to @OneLoneCoder / @Javidx9. This is basically your baby in a funny outfit.
- Unicode symbols: <https://symbl.cc/en/unicode/table/#block-elements>
