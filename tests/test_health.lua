local helpers = require("tests.helpers")
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

T["health"]["cliphist found"] = function()
	child.lua([[vim.fn.executable = function(cmd)
		if cmd == "cliphist" then return 1 end
		return 0
	end]])
	child.lua([[Config.setup({})]])

	local results = child.check_health()
	equal(results.ok[1], "{cliphist} found.")
end

T["health"]["cliphist not found"] = function()
	child.lua([[vim.fn.executable = function(cmd)
		if cmd == "cliphist" then return 0 end
		return 1
	end]])
	child.lua([[Config.setup({})]])

	local results = child.check_health()
	equal(results.error[1], "{cliphist} not found.")
end

return T
