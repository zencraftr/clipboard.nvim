local M = {}

local core = require("clipboard.core")
local config = require("clipboard.config")

---Setup the commands used with the plugin.
---@return nil
local function setup_commands()
	-- Save clipboard history entry to clipboard ready to be pasted
	vim.api.nvim_create_user_command("ClipboardYank", function()
		core.yank_clipboard()
	end, { desc = "Load clipboard history" })

	-- Insert clipboard history entry directly into the buffer
	vim.api.nvim_create_user_command("ClipboardInsert", function()
		core.insert_clipboard()
	end, { desc = "Insert clipboard history" })
end

---Setup the plugin.
---@param custom_opts Config
---@return nil
function M.setup(custom_opts)
	config.setup(custom_opts)
	setup_commands()
end

return M
