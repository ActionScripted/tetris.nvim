local utils = {}

---@param str string
---@return table
utils.string_to_table = function(str)
  local lines = {}
  for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

--[[
Get the rotated index of the shape piece.

Shape pieces are part of a 1D-as-2D array.
From top left to bottom right we count/index.
Given the x,y of a piece of a shape with w/h
we calculate the rotated index.

Example using a non-standard 2x2 shape:

██
  ██

The 1D-as-2D data is "X..X" with size 2 (2x2).

Indexing the array with zero rotation:

X . <-> 0 1
. X <-> 2 3

After a 90 degrees clockwise rotation:

. X <-> 2 0
X . <-> 3 1

Rotation 0:  Rotation 90:
0 -> X       2 -> .
1 -> .       0 -> X
2 -> .       3 -> X
3 -> X       1 -> .

The rotation maps original (x, y) coordinates to new
positions, effectively rotating the shape within its
array representation. The indexes are recalculated
to reflect the new positions of each piece.
]]
---@param x number
---@param y number
---@param size number
---@param rotation number
---@return number
utils.rotated_index = function(x, y, size, rotation)
  local r = rotation % 4
  local index = 0

  if r == 0 then
    -- 0 rotation: (x, y) -> (x, y)
    index = y * size + x
  elseif r == 1 then
    -- 90 degrees clockwise: (x, y) -> (size - 1 - y, x)
    index = (size - 1 - x) * size + y
  elseif r == 2 then
    -- 180 degrees clockwise: (x, y) -> (size - 1 - x, size - 1 - y)
    index = (size - 1 - y) * size + (size - 1 - x)
  elseif r == 3 then
    -- 270 degrees clockwise: (x, y) -> (y, size - 1 - x)
    index = x * size + (size - 1 - y)
  end

  return index
end

return utils
