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

return utils
