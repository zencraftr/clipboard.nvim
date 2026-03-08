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

	return child
end

return Helpers
