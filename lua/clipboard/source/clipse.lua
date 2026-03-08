local M = {}

local config = require("clipboard.config")

M.name = "clipse"

local function trim(s)
	return s:match("^[ \n]*(.-[ \n]*)$")
end

local function get_clipse_history_file()
	local config_file = vim.fn.expand("~/.config/clipse/config.json")

	if vim.fn.filereadable(config_file) == 0 then
		return nil
	end

	local raw = table.concat(vim.fn.readfile(config_file), "\n")
	local ok, data = pcall(vim.json.decode, raw)
	if not ok then
		return nil
	end

	if not data.historyFile then
		return nil
	end

	return "~/.config/clipse/" .. data.historyFile
end

---Fetches clipboard history entries from clipse.
---@return table[] entries
function M.get_entries()
	local path = vim.fn.expand(get_clipse_history_file() or "~/.config/clipse/clipboard_history.json")

	if vim.fn.filereadable(path) == 0 then
		return {}
	end

	local raw = table.concat(vim.fn.readfile(path), "\n")
	local ok, data = pcall(vim.json.decode, raw)
	if not ok then
		return {}
	end

	local entries = {}

	for i, entry in ipairs(data.clipboardHistory) do
		local text = trim(entry.value)
		if text ~= "" then
			table.insert(entries, { text = text, value = text, idx = i, preview = { text = text, ft = "text" } })
		end
	end

	return entries
end

return M
