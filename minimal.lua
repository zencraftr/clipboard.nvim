vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
	--TODO: Change the configuration for clipboard.nvim as needed.
	{
		"zencraftr/clipboard.nvim",
		dependencies = {
			"folke/snacks.nvim",
			-- "nvim-telescope/telescope.nvim",
		},
		opts = {
			source = "native",
			-- NOTE: You will need to have clipse installed before running this plugin.
			-- source = "clipse",

			picker = "snacks",

			-- Change the notification as per your config where the bug occured.
			notification = {
				msg = "Copied from history",
				clr = "Cleared history",
				annote = "Clipboard",
			},
		},
	},
}

require("lazy.minit").repro({ spec = plugins })

-- Uncomment and modify keymaps as needed for testing

-- vim.keymap.set("n", "<leader>p", "<cmd>ClipboardYank<cr>", { desc = "Open clipboard history" })
-- vim.keymap.set("n", "<leader>P", "<cmd>ClipboardInsert<cr>", { desc = "Insert from clipboard history" })
-- vim.keymap.set("n", "<leader>c", "<cmd>ClipboardClear<cr>", { desc = "Clear clipboard history" })
