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

T["config"] = MiniTest.new_set()

T["config"]["opts match defaults when setup() is called without arguments"] = function()
	equal(child.lua_get([[ Config.opts ]]), child.lua_get([[ Config.defaults ]]))
end

T["config"]["opts are overridden by custom values"] = function()
	child.lua([[Config.setup({ notification = false })]])
	equal(child.lua_get([[ Config.opts.picker ]]), "snacks")
	equal(child.lua_get([[ Config.opts.notification ]]), false)

	child.lua([[Config.setup({ notification = { msg = "Test notification", annote = "Test"}})]])
	equal(child.lua_get([[ Config.opts.picker ]]), "snacks")
	equal(child.lua_get([[ Config.opts.notification ]]), { msg = "Test notification", annote = "Test" })
end

T["config"]["opts revert to defaults when setup is called again with empty table"] = function()
	child.lua([[Config.setup({ picker = "snacks", notification = false })]])
	equal(child.lua_get([[ Config.opts.picker ]]), "snacks")
	equal(child.lua_get([[ Config.opts.notification ]]), false)

	child.lua([[Config.setup({})]])
	equal(child.lua_get([[ Config.opts ]]), child.lua_get([[ Config.defaults ]]))
end

return T
