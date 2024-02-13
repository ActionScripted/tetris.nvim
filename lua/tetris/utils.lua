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

---@param constants TetrisConstants
---@param state TetrisState
---@param shape TetrisShape
---@param x number
---@param y number
---@param rotation number
utils.can_move = function(constants, state, shape, x, y, rotation)
  for sy = 0, shape.size - 1 do
    for sx = 0, shape.size - 1 do
      local index = utils.rotated_index(sx, sy, shape.size, rotation)
      local char = shape.data:sub(index + 1, index + 1)

      if char == "X" then
        if sx + x < 0 or sx + x >= constants.field_width then
          return false
        end

        if sy + y >= constants.field_height - 2 then
          return false
        end

        local field_index = (constants.field_width * (sy + y)) + sx + x
        if state.field[field_index] ~= constants.field_empty then
          return false
        end
      end
    end
  end

  return true
end

utils.add_to_field = function(constants, state, shape, x, y, rotation)
  for sy = 0, shape.size - 1 do
    for sx = 0, shape.size - 1 do
      local index = utils.rotated_index(sx, sy, shape.size, rotation)
      local char = shape.data:sub(index + 1, index + 1)
      if char == "X" then
        local field_index = (constants.field_width * (sy + y)) + sx + x
        state.field[field_index] = shape.color
      end
    end
  end
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

  if r == 0 then
    -- 0 rotation: (x, y) -> (x, y)
    return y * size + x
  elseif r == 1 then
    -- 90 degrees clockwise: (x, y) -> (size - 1 - y, x)
    return (size - 1 - x) * size + y
  elseif r == 2 then
    -- 180 degrees clockwise: (x, y) -> (size - 1 - x, size - 1 - y)
    return (size - 1 - y) * size + (size - 1 - x)
  elseif r == 3 then
    -- 270 degrees clockwise: (x, y) -> (y, size - 1 - x)
    return x * size + (size - 1 - y)
  end

  return -1
end

return utils
