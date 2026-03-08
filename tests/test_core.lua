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

T["notify"] = MiniTest.new_set()

T["notify"]["default notification"] = function()
	child.notify()
	child.lua([[Core.notify()]])
	equal(child.get_notifications()[1].msg, child.lua_get([[Config.defaults.notification.msg]]))
	equal(child.get_notifications()[1].opts.annote, child.lua_get([[Config.defaults.notification.annote]]))
	equal(child.get_notifications()[1].level, vim.log.levels.INFO)
end

T["notify"]["custom notification"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = { msg = "Test message", annote = "Test annote" } })]])
	child.lua([[Core.notify()]])
	equal(
		child.get_notifications()[1],
		{ msg = "Test message", level = vim.log.levels.INFO, opts = { annote = "Test annote" } }
	)
end

T["notify"]["disable notification"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = false })]])
	child.lua([[Core.notify()]])
	equal(#child.get_notifications(), 0)
end

return T
