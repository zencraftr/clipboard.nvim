local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = child.start,
		pre_case = function()
			child.clean()
			child.mock_snacks_picker()
		end,
		post_once = child.stop,
	},
})

T["notify"] = MiniTest.new_set()

-- _notify() is a private helper; test its behaviour through the public API.

T["notify"]["yank sends default msg notification"] = function()
	child.notify()
	child.lua([[Core.yank_clipboard()]])
	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		confirm({ close = function() end }, { text = "text" })
	]])
	equal(child.get_notifications()[1].msg, child.lua_get([[Config.defaults.notification.msg]]))
	equal(child.get_notifications()[1].opts.annote, child.lua_get([[Config.defaults.notification.annote]]))
	equal(child.get_notifications()[1].level, vim.log.levels.INFO)
end

T["notify"]["yank sends custom notification"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = { msg = "Test message", annote = "Test annote" } })]])
	child.lua([[Core.yank_clipboard()]])
	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		confirm({ close = function() end }, { text = "text" })
	]])
	equal(
		child.get_notifications()[1],
		{ msg = "Test message", level = vim.log.levels.INFO, opts = { annote = "Test annote" } }
	)
end

T["notify"]["no notification when disabled"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = false })]])
	child.lua([[Core.yank_clipboard()]])
	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		confirm({ close = function() end }, { text = "text" })
	]])
	equal(#child.get_notifications(), 0)
end

T["yank_clipboard"] = MiniTest.new_set()

T["yank_clipboard"]["opens picker and yanks selected text to clipboard"] = function()
	child.lua([[
		-- Mock clipboard register for CI environments without clipboard provider
		_G._clipboard_plus = ""
		local orig_setreg = vim.fn.setreg
		local orig_getreg = vim.fn.getreg
		vim.fn.setreg = function(reg, val) if reg == "+" then _G._clipboard_plus = val else orig_setreg(reg, val) end end
		vim.fn.getreg = function(reg) if reg == "+" then return _G._clipboard_plus else return orig_getreg(reg) end end
	]])

	child.notify()
	child.lua([[Core.yank_clipboard()]])

	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, { text = "Yanked text" })
	]])

	equal(child.lua_get([[_G._clipboard_plus]]), "Yanked text")
	equal(#child.get_notifications(), 1)
end

T["yank_clipboard"]["does not yank when picker is cancelled"] = function()
	child.lua([[
		-- Mock clipboard register for CI environments without clipboard provider
		_G._clipboard_plus = "Original"
		local orig_setreg = vim.fn.setreg
		local orig_getreg = vim.fn.getreg
		vim.fn.setreg = function(reg, val) if reg == "+" then _G._clipboard_plus = val else orig_setreg(reg, val) end end
		vim.fn.getreg = function(reg) if reg == "+" then return _G._clipboard_plus else return orig_getreg(reg) end end
	]])

	child.notify()
	child.lua([[Core.yank_clipboard()]])

	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, nil)
	]])

	equal(child.lua_get([[_G._clipboard_plus]]), "Original")
	equal(#child.get_notifications(), 0)
end

T["insert_clipboard"] = MiniTest.new_set()

T["insert_clipboard"]["opens picker and inserts selected text at cursor"] = function()
	child.notify()
	child.lua([[Core.insert_clipboard()]])

	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, { text = "Inserted text" })
	]])

	equal(child.lua_get([[vim.api.nvim_get_current_line()]]), "Inserted text")
	equal(#child.get_notifications(), 1)
end

T["insert_clipboard"]["does not insert when picker is cancelled"] = function()
	child.lua([[vim.api.nvim_set_current_line("Original line")]])

	child.notify()
	child.lua([[Core.insert_clipboard()]])

	-- Simulate picker cancel (nil entry)
	child.lua([[
		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, nil)
	]])

	equal(child.lua_get([[vim.api.nvim_get_current_line()]]), "Original line")
	equal(#child.get_notifications(), 0)
end

T["clear_clipboard"] = MiniTest.new_set()

T["clear_clipboard"]["calls source clear and sends clr notification"] = function()
	child.notify()
	child.lua([[
		_G._clear_called = false
		local source = require("clipboard.source." .. Config.opts.source)
		source.clear = function() _G._clear_called = true end
	]])
	child.lua([[Core.clear_clipboard()]])
	equal(child.lua_get([[_G._clear_called]]), true)
	equal(#child.get_notifications(), 1)
	equal(child.get_notifications()[1].msg, child.lua_get([[Config.defaults.notification.clr]]))
	equal(child.get_notifications()[1].opts.annote, child.lua_get([[Config.defaults.notification.annote]]))
	equal(child.get_notifications()[1].level, vim.log.levels.INFO)
end

T["clear_clipboard"]["does not notify when notification is disabled"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = false })]])
	child.lua([[
		local source = require("clipboard.source." .. Config.opts.source)
		source.clear = function() end
	]])
	child.lua([[Core.clear_clipboard()]])
	equal(#child.get_notifications(), 0)
end

T["clear_clipboard"]["sends custom clr notification message"] = function()
	child.notify()
	child.lua([[Config.setup({ notification = { clr = "Custom cleared", annote = "Custom" } })]])
	child.lua([[
		local source = require("clipboard.source." .. Config.opts.source)
		source.clear = function() end
	]])
	child.lua([[Core.clear_clipboard()]])
	equal(child.get_notifications()[1].msg, "Custom cleared")
	equal(child.get_notifications()[1].opts.annote, "Custom")
end

return T
