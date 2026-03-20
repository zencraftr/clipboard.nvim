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

	-- Setup the native source YankTextPost autocommand and filepath of the history file
	if M.opts.source == "native" then
		require("clipboard.source." .. M.opts.source).setup()
	end

	-- Start the clipse daemon to capture clipboard events from external applications
	if M.opts.source == "clipse" and vim.fn.executable("clipse") == 1 then
		vim.system({ "clipse", "-listen" })
	end
end

return M
