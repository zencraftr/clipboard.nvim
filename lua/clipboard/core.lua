local M = {}

local config = require("clipboard.config")

---Sends a notification based on config.
---@return nil
function M.notify()
	-- If notification is a table, use the custom msg and annote
	if type(config.opts.notification) == "table" then
		vim.notify(config.opts.notification.msg, vim.log.levels.INFO, { annote = config.opts.notification.annote })
		return
	end

	-- If notification is true, use defaults
	if config.opts.notification then
		vim.notify(
			config.defaults.notification.msg,
			vim.log.levels.INFO,
			{ annote = config.defaults.notification.annote }
		)
		return
	end
end

---Opens the clipboard history picker and yanks the selected item to the clipboard.
---@return nil
function M.yank_clipboard()
	require("clipboard.picker." .. config.opts.picker).pick(function(text)
		vim.fn.setreg("+", text)
		M.notify()
	end)
end

---Opens the clipboard history picker and pastes the selected item at the cursor position.
---@return nil
function M.insert_clipboard()
	require("clipboard.picker." .. config.opts.picker).pick(function(text)
		vim.api.nvim_paste(text, true, -1)
		M.notify()
	end)
end

return M
