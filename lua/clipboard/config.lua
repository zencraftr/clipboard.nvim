local M = {}

---@type Config
M.defaults = {
	picker = "snacks",
}

---@param custom_opts Config
function M.setup(custom_opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.defaults, custom_opts or {})
end

return M
