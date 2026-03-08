local M = {}

---@type Config
M.defaults = {
	-- Clipboard provider ("clipse" is currently the only supported option)
	source = "clipse",

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

---@param custom_opts Config Custom configuration options
function M.setup(custom_opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.defaults, custom_opts or {})
end

return M
