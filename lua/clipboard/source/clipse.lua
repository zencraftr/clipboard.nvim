local util = require("clipboard.utils")

local M = {}

M.name = "clipse"

-- Default history file location used when no custom path is set in the clipse config.
local _default_history_file = "~/.config/clipse/clipboard_history.json"

---Get the clipse history file specified in the clipse configuration, falling back to the
---default path when no config is present or the config does not specify a custom file.
---@return string filePath The clipboard history file path.
local function get_clipse_history_file()
	local config_file = vim.fn.expand("~/.config/clipse/config.json")

	if vim.fn.filereadable(config_file) == 0 then
		return vim.fn.expand(_default_history_file)
	end

	local raw = table.concat(vim.fn.readfile(config_file), "\n")
	local ok, data = pcall(vim.json.decode, raw)
	if not ok or not data.historyFile then
		return vim.fn.expand(_default_history_file)
	end

	return vim.fn.expand("~/.config/clipse/" .. data.historyFile)
end

---Fetches clipboard history entries from clipse.
---@return table[] entries The clipboard history entries
function M.get_entries()
	local path = get_clipse_history_file()

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
		local text = util.trim(entry.value)
		if text ~= "" then
			table.insert(entries, { text = text, value = text, idx = i, preview = { text = text, ft = "text" } })
		end
	end

	return entries
end

---Clears clipse clipboard history.
---@return nil
function M.clear()
	vim.system({ "clipse", "-clear-all" })
end

---Setup the native clipboard history.
---@return nil
function M.setup()
	-- Clipse listening for copy event
	vim.system({ "clipse", "-listen" }, { text = true }, function() end)
end

return M
