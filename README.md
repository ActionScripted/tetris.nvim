# tetris.nvim

Pure Lua tetris game for Neovim.

## Installation

Using lazy.nvim:

```lua
{
  "ActionScripted/tetris.nvim",
  cmd = { "Tetris" },
  opts = {},
}
```

## Configuration

TODO. But right now, nothing to configure. EZPZ.

## Development

Leaning on [Lua Language Server](https://luals.github.io/) for annotations and docs.

We're trying to follow the Super Rotation System (SRS) that dictates how pieces spawn and rotate. This also includes stuff like wall kicks, infinity and other terrific tetromino-related terminology.

- <https://tetris.wiki/Super_Rotation_System>
- <https://harddrop.com/wiki/SRS>
