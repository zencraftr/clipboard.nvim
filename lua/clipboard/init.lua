local M = {}

local core = require("clipboard.core")
local config = require("clipboard.config")

local function setup_commands()
	-- save clipboard history entry to clipboard ready to be pasted
	vim.api.nvim_create_user_command("ClipboardHistory", function()
		core.yank_clipboard()
	end, { desc = "Load clipboard history" })

	-- insert clipboard history entry directly into the buffer
	vim.api.nvim_create_user_command("ClipboardInsert", function()
		core.insert_clipboard()
	end, { desc = "Insert clipboard history" })
end

---@param custom_opts Config
function M.setup(custom_opts)
	config.setup(custom_opts)
	setup_commands()
end

return M
