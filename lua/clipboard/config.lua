local M = {}

---@type Config
M.defaults = {
	-- Clipboard provider options:
	-- native				Internal clipboard manager (supports yanked text in Neovim)
	-- clipse				TUI clipboard manager (supports external yanked text)
	source = "native",

	-- Picker provider ("snacks" is currently the only supported option)
	picker = "snacks",

	-- Possible values for notification:
	-- false                Disable notifications
	-- true                 Use the default message and annotation
	-- { msg, annote }      Define a custom message and annotation
	notification = {
		msg = "Copied to clipboard",
		annote = "Clipboard",
	},
}

---Setup the plugin configuration.
---@param custom_opts Config Custom configuration options
---@return nil
function M.setup(custom_opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.defaults, custom_opts or {})

	-- Setup the native source YankTextPost autocommand and filepath of the history file
	if M.opts.source == "native" then
		require("clipboard.source." .. M.opts.source).setup()
	end
end

return M
