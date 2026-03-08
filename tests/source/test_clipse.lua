local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = child.start,
		pre_case = function()
			child.clean()
			child.mock_clipse_dir()
		end,
		post_case = child.restore_clipse_dir,
		post_once = child.stop,
	},
})

T["clipse"] = MiniTest.new_set()

T["clipse"]["get_entries() returns empty table when history file does not exist"] = function()
	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(entries, {})
end

T["clipse"]["get_entries() returns empty table when history file contains invalid JSON"] = function()
	child.lua([[
		vim.fn.writefile({ "Invalid JSON" }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])
	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(entries, {})
end

T["clipse"]["get_entries parses valid clipboard history"] = function()
	child.lua([[
		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "First entry" },
				{ value = "Second entry" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "First entry")
	equal(entries[1].idx, 1)
	equal(entries[2].text, "Second entry")
	equal(entries[2].idx, 2)
end

T["clipse"]["get_entries skips empty entries"] = function()
	child.lua([[
		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "Valid entry" },
				{ value = "   " },
				{ value = "" },
				{ value = "\n" },
				{ value = "Another valid entry" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(#entries, 2)
	equal(entries[1].text, "Valid entry")
	equal(entries[1].idx, 1)
	equal(entries[2].text, "Another valid entry")
	equal(entries[2].idx, 5)
end

T["clipse"]["entries have correct structure with preview"] = function()
	child.lua([[
		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "Test content" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(entries[1].text, "Test content")
	equal(entries[1].value, "Test content")
	equal(entries[1].idx, 1)
	equal(entries[1].preview, { text = "Test content", ft = "text" })
end

T["clipse"]["uses history file from clipse config when available"] = function()
	child.lua([[
		local config_content = vim.json.encode({ historyFile = "custom_history.json" })
		vim.fn.writefile({ config_content }, _G._test_clipse_dir .. "/config.json")

		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "From custom history file" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/custom_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "From custom history file")
end

T["clipse"]["falls back to default history file when config is invalid"] = function()
	child.lua([[
		vim.fn.writefile({ "invalid json" }, _G._test_clipse_dir .. "/config.json")

		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "From default history file" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "From default history file")
end

T["clipse"]["falls back to default when config has no historyFile field"] = function()
	child.lua([[
		local config_content = vim.json.encode({ someOtherSetting = true })
		vim.fn.writefile({ config_content }, _G._test_clipse_dir .. "/config.json")

		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "Fallback default file entry" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	local entries = child.lua_get([[Clipse.get_entries()]])
	equal(#entries, 1)
	equal(entries[1].text, "Fallback default file entry")
end

return T
