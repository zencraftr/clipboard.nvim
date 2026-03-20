local M = {}

local config = require("clipboard.config")

---Send a notification
---@param key string The type of notification to send ("msg", "clr")
---@return nil
local function _notify(key)
	if not config.opts.notification then
		return
	end

	local msg = type(config.opts.notification) == "table" and config.opts.notification[key]
		or config.defaults.notification[key]

	local annote = type(config.opts.notification) == "table" and config.opts.notification.annote
		or config.defaults.notification.annote

	vim.notify(msg, vim.log.levels.INFO, { annote = annote })
end

---Opens the clipboard history picker and yanks the selected item to the clipboard.
---@return nil
function M.yank_clipboard()
	require("clipboard.picker." .. config.opts.picker).pick(function(text)
		vim.fn.setreg("+", text)
		vim.fn.setreg('"', text)
		_notify("msg")
	end)
end

---Opens the clipboard history picker and pastes the selected item at the cursor position.
---@return nil
function M.insert_clipboard()
	require("clipboard.picker." .. config.opts.picker).pick(function(text)
		vim.api.nvim_paste(text, true, -1)
		_notify("msg")
	end)
end

---Clears the clipboard history to a clean slate.
---@return nil
function M.clear_clipboard()
	require("clipboard.source." .. config.opts.source).clear()
	_notify("clr")
end

return M
