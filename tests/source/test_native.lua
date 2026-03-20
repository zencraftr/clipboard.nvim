local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = child.start,
		pre_case = child.clean_native,
		post_case = child.restore_native_dir,
		post_once = child.stop,
	},
})

T["native"] = MiniTest.new_set()

-- Helper: write a JSON history array to the mocked history file and reload the native module.
-- This simulates restarting Neovim with an existing history file on disk.
local function load_history(child_instance, entries)
	child_instance.lua(string.format(
		[[
		local history = vim.json.encode(%s)
		local history_file = _G._test_native_dir .. "/clipboard.nvim/history-native.json"
		vim.fn.mkdir(vim.fn.fnamemodify(history_file, ":h"), "p")
		vim.fn.writefile({ history }, history_file)

		package.loaded["clipboard.source.native"] = nil
		Native = require("clipboard.source.native")
		Native.setup()
	]],
		entries
	))
end

T["native"]["get_entries() returns empty table when history is empty"] = function()
	local entries = child.lua_get([[Native.get_entries()]])
	equal(entries, {})
end

T["native"]["get_entries() returns entries with correct structure"] = function()
	load_history(child, [[{ { text = "structured entry", timestamp = 1000, ft = "lua" } }]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "structured entry")
	equal(entries[1].value, "structured entry")
	equal(entries[1].idx, 1)
	equal(entries[1].preview, { text = "structured entry", ft = "lua" })
end

T["native"]["get_entries() skips empty and whitespace-only entries"] = function()
	load_history(
		child,
		[[{
		{ text = "valid entry",    timestamp = 1000, ft = "text" },
		{ text = "   ",            timestamp = 1001, ft = "text" },
		{ text = "",               timestamp = 1002, ft = "text" },
		{ text = "\n",             timestamp = 1003, ft = "text" },
		{ text = "another valid",  timestamp = 1004, ft = "text" },
	}]]
	)

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "valid entry")
	equal(entries[2].text, "another valid")
end

T["native"]["get_entries() trims leading and trailing whitespace from entries"] = function()
	load_history(child, [[{ { text = "  trimmed  ", timestamp = 1000, ft = "text" } }]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "trimmed")
end

T["native"]["setup() loads existing history from file"] = function()
	load_history(
		child,
		[[{
		{ text = "first",  timestamp = 2000, ft = "lua" },
		{ text = "second", timestamp = 1000, ft = "text" },
	}]]
	)

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "first")
	equal(entries[2].text, "second")
end

T["native"]["setup() creates the data directory if it does not exist"] = function()
	child.lua([[
		vim.fn.delete(_G._test_native_dir .. "/clipboard.nvim", "rf")

		package.loaded["clipboard.source.native"] = nil
		Native = require("clipboard.source.native")
		Native.setup()
	]])

	local dir_exists = child.lua_get([[vim.fn.isdirectory(_G._test_native_dir .. "/clipboard.nvim") == 1]])
	equal(dir_exists, true)
end

T["native"]["setup() tolerates a missing history file without error"] = function()
	-- clean_native already calls setup() against an empty dir; get_entries() must return {}
	local entries = child.lua_get([[Native.get_entries()]])
	equal(entries, {})
end

T["native"]["TextYankPost adds yanked text to history"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "hello world")
end

T["native"]["TextYankPost inserts new entries at the front"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first yank" })
		vim.cmd("normal! yy")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "second yank" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "second yank")
	equal(entries[2].text, "first yank")
end

T["native"]["TextYankPost deduplicates: bumps existing entry to front"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "text A" })
		vim.cmd("normal! yy")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "text B" })
		vim.cmd("normal! yy")
		-- Yanking text A again should move it back to the front
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "text A" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "text A")
	equal(entries[2].text, "text B")
end

T["native"]["TextYankPost captures the buffer filetype"] = function()
	child.lua([[
		vim.bo.filetype = "python"
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "def foo():" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].preview.ft, "python")
end

T["native"]["TextYankPost defaults filetype to 'text' when buffer has none"] = function()
	child.lua([[
		vim.bo.filetype = ""
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "no filetype here" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].preview.ft, "text")
end

T["native"]["TextYankPost saves history to file after yank"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "persisted text" })
		vim.cmd("normal! yy")
	]])

	local file_exists =
		child.lua_get([[vim.fn.filereadable(_G._test_native_dir .. "/clipboard.nvim/history-native.json") == 1]])
	equal(file_exists, true)

	-- Reload the module from the file it wrote; the entry must survive a restart
	child.lua([[
		package.loaded["clipboard.source.native"] = nil
		Native = require("clipboard.source.native")
		Native.setup()
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "persisted text")
end

T["native"]["clear() empties the in-memory history"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "some text" })
		vim.cmd("normal! yy")
	]])
	equal(#child.lua_get([[Native.get_entries()]]), 1)

	child.lua([[Native.clear()]])

	equal(child.lua_get([[Native.get_entries()]]), {})
end

T["native"]["clear() persists the cleared state to disk"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "persisted text" })
		vim.cmd("normal! yy")
	]])

	child.lua([[Native.clear()]])

	-- Reload native from disk to verify the cleared state survived a restart
	child.lua([[
		package.loaded["clipboard.source.native"] = nil
		Native = require("clipboard.source.native")
		Native.setup()
	]])

	equal(child.lua_get([[Native.get_entries()]]), {})
end

T["native"]["clear() allows new entries to be added after clearing"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "old text" })
		vim.cmd("normal! yy")
	]])

	child.lua([[Native.clear()]])

	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "new text" })
		vim.cmd("normal! yy")
	]])

	local entries = child.lua_get([[Native.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "new text")
end

return T
