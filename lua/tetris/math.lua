--- Math utility functions.
--- Note that we are snapping these directly to the math library. If you hate it,
--- open a PR and refactor and do `local tetris_math = require("tetris.math")` or
--- something and then I will comment about how ugly that is and we can bicker in
--- public. I will eventually concede and merge your PR. ;)

---Clamp a number between a minimum and maximum value.
---@param x number Value to clamp
---@param min number Minimum value
---@param max number Maximum value
function math.clamp(x, min, max)
  return math.max(math.min(x, max), min)
end
