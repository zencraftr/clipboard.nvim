local M = {}

local function check_lua_module(name)
	local package_found, _ = pcall(require, name)
	return package_found
end

local function check_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

---Validates that all required external dependencies are present.
---@return nil
local function check_requirements()
	-- cliphist package
	if check_executable("cliphist") then
		vim.health.ok("{cliphist} found.")
	else
		vim.health.error("{cliphist} not found.")
	end

	-- picker provider
	if check_lua_module("snacks.picker") then
		vim.health.ok("{snacks.picker} found.")
	else
		vim.health.error("{snacks.picker} not found.")
	end
end

---Performs a `:checkhealth` check `clipboard.nvim`.
function M.check()
	vim.health.start("Requirements")
	check_requirements()
end

return M
