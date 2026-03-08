local M = {}

local config = require("clipboard.config")

---Checks if a Lua module can be required.
---@param name string The name of the Lua module to check.
---@return boolean
local function check_lua_module(name)
	local package_found, _ = pcall(require, name)
	return package_found
end

---Checks if an executable is available in the system.
---@param cmd string The name of the executable to check.
---@return boolean
local function check_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

---Validates the user configuration.
---@return nil
local function check_configuration()
	-- picker provider
	if config.opts.picker == "snacks" then
		vim.health.ok("{snacks.picker} picker option.")
	else
		vim.health.error("{" .. tostring(config.opts.picker) .. "} invalid picker option.")
	end

	-- source provider
	if config.opts.source == "clipse" then
		vim.health.ok("{" .. tostring(config.opts.source) .. "} source option.")
	else
		vim.health.error("{" .. tostring(config.opts.source) .. "} invalid source option.")
	end

	-- notification config
	if type(config.opts.notification) == "boolean" then
		vim.health.ok("{" .. tostring(config.opts.notification) .. "} notification option.")
	elseif type(config.opts.notification) == "table" then
		if type(config.opts.notification.msg) == "string" and type(config.opts.notification.annote) == "string" then
			vim.health.ok("{notification} notification option.")
		else
			vim.health.error("{notification} invalid notification option.")
		end
	else
		vim.health.error("{notification} invalid notification option.")
	end
end

---Validates that all required external dependencies are present.
---@return nil
local function check_requirements()
	-- clipboard source package
	if check_executable(config.opts.source) then
		vim.health.ok("{" .. config.opts.source .. "} found.")
	else
		vim.health.error("{" .. config.opts.source .. "} not found.")
	end

	-- picker provider
	if check_lua_module("snacks.picker") then
		vim.health.ok("{snacks.picker} found.")
	else
		vim.health.warn("{snacks.picker} not found.")
	end
end

---Performs a `:checkhealth` check `clipboard.nvim`.
function M.check()
	vim.health.start("Configuration")
	check_configuration()

	vim.health.start("Requirements")
	check_requirements()
end

return M
