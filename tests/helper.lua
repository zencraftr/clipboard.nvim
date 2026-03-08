local Helpers = {}

Helpers.new_child_neovim = function()
	local child = MiniTest.new_child_neovim()

	child.clean = function()
		child.restart({ "-u", "scripts/minimal_init.lua" })
		child.bo.readonly = false
		child.lua([[
			M = require('clipboard')

			Config = require('clipboard.config')
			Config.setup() -- Needs to be called just like a plugin manager would to initialise the plugin.

			Core = require('clipboard.core')
			Health = require('clipboard.health')
		]])
	end

	child.check_health = function()
		return child.lua_get([[ (function()
			local results = { ok = {}, warn = {}, error = {} }
			vim.health.ok = function(msg) table.insert(results.ok, msg) end
			vim.health.warn = function(msg) table.insert(results.warn, msg) end
			vim.health.error = function(msg) table.insert(results.error, msg) end
			vim.health.start = function(_) end

			Health.check()
			return results
		end)()]])
	end

	child.notify = function()
		child.lua([[
		_G._notifications = {}
        vim.notify = function(msg, level, opts)
            table.insert(_G._notifications, {
                msg   = msg,
                level = level,
                opts  = opts,
            })
        end]])
	end

	child.get_notifications = function()
		return child.lua_get([[_G._notifications]])
	end

	child.mock_clipse_dir = function()
		child.lua([[
			_G._test_clipse_dir = vim.fn.tempname()
			vim.fn.mkdir(_G._test_clipse_dir, "p")

			_G._original_expand = vim.fn.expand
			vim.fn.expand = function(path)
				if path:match("^~/.config/clipse") then
					return path:gsub("^~/.config/clipse", _G._test_clipse_dir)
				end
				return _G._original_expand(path)
			end
			Clipse = require('clipboard.source.clipse')
		]])
	end

	child.restore_clipse_dir = function()
		child.lua([[
			vim.fn.expand = _G._original_expand
			vim.fn.delete(_G._test_clipse_dir, "rf")
		]])
	end

	child.mock_snacks_picker = function()
		child.lua([[
			_G._picker_calls = {}
			package.loaded["snacks.picker"] = {
				pick = function(name, opts)
					table.insert(_G._picker_calls, { name = name, opts = opts })
				end,
			}
			SnacksPicker = require('clipboard.picker.snacks')
		]])
	end

	return child
end

return Helpers
