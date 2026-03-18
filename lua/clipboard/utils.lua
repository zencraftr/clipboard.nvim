local M = {}

---Trim leading and trailing spaces and new lines.
---@param str string The text to trim
---@return string trimmedStr The trimmed text
function M.trim(str)
	return str:match("^[ \n]*(.-)[ \n]*$")
end

return M
