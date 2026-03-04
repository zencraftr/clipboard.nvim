local M = {}

local config = require("clipboard.config")

local function get_picker()
	local ok, picker = pcall(require, "snacks.picker")
	if not ok then
		vim.notify("[clipboard.nvim] snacks.picker not found. Is snacks.nvim installed?", vim.log.levels.ERROR)
		return nil
	end
	return picker
end

function M.yank_clipboard()
	local picker = get_picker()
	if picker then
		picker.cliphist()
	end
end

function M.insert_clipboard()
	local picker = get_picker()
	if not picker then
		return
	end

	picker.cliphist({
		confirm = function(p, item)
			p:close()
			if item then
				vim.schedule(function()
					local text = item.data or item.text
					local lines = vim.split(text, "\n", { plain = true })
					if lines[#lines] == "" then
						table.remove(lines, #lines)
					end
					vim.api.nvim_put(lines, "c", true, true)
				end)
			end
		end,
	})
end

return M
