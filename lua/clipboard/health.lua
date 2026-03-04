local M = {}

local function check_lua_module(name)
	local package_found, _ = pcall(require, name)
	return package_found
end

local function check_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

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

local function check_config()
	local config = require("clipboard.config")
	if not config.opts then
		vim.health.error("setup() has not been called. Add `opts = {}` to your plugin spec.")
		return
	end
	if config.opts.picker == "snacks" then
		vim.health.ok('picker = "snacks"')
	else
		vim.health.warn('Unknown picker: "' .. tostring(config.opts.picker) .. '". Only "snacks" is supported.')
	end
end

function M.check()
	vim.health.start("Configuration")
	check_config()

	vim.health.start("Requirements")
	check_requirements()
end

return M
