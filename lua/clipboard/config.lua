local M = {}

---@type Config
M.defaults = {
	-- TODO: Add more pickers (e.g. telescope, fzf, etc.)
	picker = "snacks",

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
