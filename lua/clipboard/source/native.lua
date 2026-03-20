---@type NativeEntry[]
local _history = {}

---@type string
local _history_file = vim.fn.stdpath("data") .. "/clipboard.nvim/history-native.json"

local util = require("clipboard.utils")

local M = {}

M.name = "native"

---Save clipboard history to a json file.
---@return nil
local function _save()
	local ok, encoded = pcall(vim.json.encode, _history)
	if not ok then
		return
	end

	vim.fn.writefile({ encoded }, _history_file)
end

---Load clipboard history from a json file.
---@return nil
local function _load()
	local ok, lines = pcall(vim.fn.readfile, _history_file)
	if not ok then
		return
	end

	local ok_decoded, decoded = pcall(vim.json.decode, table.concat(lines, ""))
	if ok_decoded and type(decoded) == "table" then
		_history = decoded
	end
end

---If an entry with the same text already exists, move it to the front and
---update its timestamp. Otherwise insert it as a new entry at the front.
---@param entry NativeEntry
---@return nil
local function _bump_or_insert(entry)
	for i, existing in ipairs(_history) do
		if existing.text == entry.text then
			table.remove(_history, i)
			existing.timestamp = entry.timestamp
			table.insert(_history, 1, existing)
			return
		end
	end

	table.insert(_history, 1, entry)
end

---Setup TextYankPost event to copy the entry to the clipboard history.
---@return nil
local function _setup_commands()
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("Clipboard", { clear = true }),
		desc = "Add yanked text to clipboard.nvim native history",

		callback = function()
			local event = vim.v.event
			if not event.regcontents or #event.regcontents == 0 then
				return
			end

			local text = util.trim(table.concat(event.regcontents, "\n"))
			if text == "" then
				return
			end

			_bump_or_insert(
				---@type NativeEntry
				{
					text = text,
					timestamp = os.time(),
					ft = vim.bo.filetype ~= "" and vim.bo.filetype or "text",
				}
			)

			_save()
		end,
	})
end

---Setup the native clipboard history.
---@return nil
function M.setup()
	-- Create the clipboard.nvim directory if not already present
	local dir = vim.fn.fnamemodify(_history_file, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	_load()

	_setup_commands()
end

---Fetches clipboard history entries from native clipboard history.
---@return table[] entries The clipboard history entries
function M.get_entries()
	local entries = {}

	for i, entry in ipairs(_history) do
		local text = util.trim(entry.text)
		if text ~= "" then
			table.insert(entries, { text = text, value = text, idx = i, preview = { text = text, ft = entry.ft } })
		end
	end

	return entries
end

---Clears the current clipboard history.
---@return nil
function M.clear()
	_history = {}
	_save()
end

return M
