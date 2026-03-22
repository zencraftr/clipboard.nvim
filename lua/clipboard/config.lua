local M = {}

---@type ClipboardConfig
M.defaults = {
	-- Clipboard provider options:
	-- native						Internal clipboard manager (supports only yanked text in Neovim)
	-- clipse						External clipboard manager (supports external yanked text)
	source = "native",

	-- Picker provider ("snacks" is currently the only supported option)
	picker = "snacks",

	-- Possible values for notification:
	-- false						Disable notifications
	-- true							Use the default message and annotation
	-- { msg, clr, annote }			Define a custom message and annotation
	notification = {
		msg = "Copied from history",
		clr = "Cleared history",
		annote = "Clipboard",
	},
}

---Setup the plugin configuration.
---@param custom_opts ClipboardConfig Custom configuration options
---@return nil
function M.setup(custom_opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.defaults, custom_opts or {})
end

return M
