local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = child.start,
		pre_case = child.clean,
		post_once = child.stop,
	},
})

T["health"] = MiniTest.new_set()

T["health"]["reports ok when clipse executable is found"] = function()
	child.lua([[
		Config.setup({ source = "clipse" })
		vim.fn.executable = function(cmd)
			if cmd == "clipse" then return 1 end
			return 0
		end
	]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{clipse} found."), true)
end

T["health"]["reports error when clipse executable is not found"] = function()
	child.lua([[
		Config.setup({ source = "clipse" })
		vim.fn.executable = function(cmd)
			if cmd == "clipse" then return 0 end
			return 1
		end
	]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{clipse} not found."), true)
end

T["health"]["reports ok for valid picker option"] = function()
	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{snacks.picker} picker option."), true)
end

T["health"]["reports error for invalid picker option"] = function()
	child.lua([[Config.setup({ picker = "invalid" })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{invalid} invalid picker option."), true)
end

T["health"]["reports ok for valid source option clipse"] = function()
	child.lua([[Config.setup({ source = "clipse" })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{clipse} source option."), true)
end

T["health"]["reports ok for valid source option native"] = function()
	-- default source is "native"
	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{native} source option."), true)
end

T["health"]["reports error for invalid source option"] = function()
	child.lua([[Config.setup({ source = "invalid" })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{invalid} invalid source option."), true)
end

T["health"]["reports ok for native source with no external requirements"] = function()
	-- default source is "native" which requires no external programs
	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{native} not requiring external programs."), true)
end

T["health"]["reports ok when snacks.picker module is found"] = function()
	child.lua([[package.loaded["snacks.picker"] = { pick = function() end }]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{snacks.picker} found."), true)
end

T["health"]["reports warn when snacks.picker module is not found"] = function()
	child.lua([[
		package.loaded["snacks.picker"] = nil
		package.preload["snacks.picker"] = function() error("not installed") end
	]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.warn, "{snacks.picker} not found."), true)
end

T["health"]["reports ok for notification = true"] = function()
	child.lua([[Config.setup({ notification = true })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{true} notification option."), true)
end

T["health"]["reports ok for notification = false"] = function()
	child.lua([[Config.setup({ notification = false })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{false} notification option."), true)
end

T["health"]["reports ok for table notification option with valid fields"] = function()
	child.lua([[Config.setup({ notification = { msg = "Test", clr = "Cleared", annote = "Test" } })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.ok, "{notification} notification option."), true)
end

T["health"]["reports error for notification table with non-string msg"] = function()
	child.lua([[Config.setup({ notification = { msg = 123, clr = "x", annote = "x" } })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{notification} invalid notification option."), true)
end

T["health"]["reports error for notification table with non-string clr"] = function()
	child.lua([[Config.setup({ notification = { clr = false } })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{notification} invalid notification option."), true)
end

T["health"]["reports error for notification table with non-string annote"] = function()
	child.lua([[Config.setup({ notification = { annote = 999 } })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{notification} invalid notification option."), true)
end

T["health"]["reports error for notification table with missing fields"] = function()
	child.lua([[Config.opts.notification = {}]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{notification} invalid notification option."), true)
end

T["health"]["reports error for invalid notification option"] = function()
	child.lua([[Config.setup({ notification = "invalid" })]])

	local results = child.check_health()
	equal(vim.tbl_contains(results.error, "{notification} invalid notification option."), true)
end

return T
