local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = child.start,
		pre_case = function()
			child.clean()
			child.mock_clipse_dir()
			child.mock_snacks_picker()
		end,
		post_case = child.restore_clipse_dir,
		post_once = child.stop,
	},
})

T["snacks"] = MiniTest.new_set()

T["snacks"]["pick() calls snacks.picker.pick with correct name"] = function()
	child.lua([[SnacksPicker.pick(function() end)]])
	equal(child.lua_get([[_G._picker_calls[1].name]]), "clipse_history")
end

T["snacks"]["pick() passes correct title"] = function()
	child.lua([[SnacksPicker.pick(function() end)]])
	equal(child.lua_get([[_G._picker_calls[1].opts.title]]), "Clipboard History")
end

T["snacks"]["pick() passes entries as items from source"] = function()
	child.lua([[
		local history = vim.json.encode({
			clipboardHistory = {
				{ value = "Entry one" },
				{ value = "Entry two" },
			}
		})
		vim.fn.writefile({ history }, _G._test_clipse_dir .. "/clipboard_history.json")
	]])

	child.lua([[SnacksPicker.pick(function() end)]])

	local items = child.lua_get([[_G._picker_calls[1].opts.items]])
	equal(#items, 2)
	equal(items[1].text, "Entry one")
	equal(items[2].text, "Entry two")
end

T["snacks"]["pick() sets layout with preview enabled"] = function()
	child.lua([[SnacksPicker.pick(function() end)]])
	local layout = child.lua_get([[_G._picker_calls[1].opts.layout]])
	equal(layout.preset, "default")
	equal(layout.preview, true)
	equal(child.lua_get([[_G._picker_calls[1].opts.preview]]), "preview")
end

T["snacks"]["format() returns idx and text with highlight groups"] = function()
	child.lua([[SnacksPicker.pick(function() end)]])

	child.lua([[
		local format = _G._picker_calls[1].opts.format
		_G._format_result = format({ idx = 5, text = "Test item" }, {})
	]])

	local result = child.lua_get([[_G._format_result]])
	equal(result[1], { "5 ", "SnacksPickerIdx" })
	equal(result[2], { "Test item", "SnacksPickerItem" })
end

T["snacks"]["confirm() calls on_select with entry text"] = function()
	child.lua([[
		_G._selected_text = nil
		SnacksPicker.pick(function(text)
			_G._selected_text = text
		end)

		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, { text = "Selected entry" })
	]])

	equal(child.lua_get([[_G._selected_text]]), "Selected entry")
end

T["snacks"]["confirm() closes the picker"] = function()
	child.lua([[
		_G._picker_closed = false
		SnacksPicker.pick(function() end)

		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() _G._picker_closed = true end }
		confirm(mock_picker, { text = "Test" })
	]])

	equal(child.lua_get([[_G._picker_closed]]), true)
end

T["snacks"]["confirm() does not call on_select when entry is nil"] = function()
	child.lua([[
		_G._on_select_called = false
		SnacksPicker.pick(function()
			_G._on_select_called = true
		end)

		local confirm = _G._picker_calls[1].opts.confirm
		local mock_picker = { close = function() end }
		confirm(mock_picker, nil)
	]])

	equal(child.lua_get([[_G._on_select_called]]), false)
end

return T
