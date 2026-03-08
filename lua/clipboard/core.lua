local M = {}

local config = require("clipboard.config")
local ok_picker, picker = pcall(require, "snacks.picker")

---@param item SnacksPickerItem
---@return string
local function get_item_text(item)
	return item.data or item.text
end

---Sends a notification based on config.
---@return nil
function M.notify()
	-- If notification is a table, use the custom msg and annote
	if type(config.opts.notification) == "table" then
		vim.notify(config.opts.notification.msg, vim.log.levels.INFO, { annote = config.opts.notification.annote })
		return
	end

	-- If notification is true, use defaults
	if config.opts.notification then
		vim.notify(
			config.defaults.notification.msg,
			vim.log.levels.INFO,
			{ annote = config.defaults.notification.annote }
		)
		return
	end
end

---Opens the clipboard history picker and yanks the selected item to the clipboard.
---@return nil
function M.yank_clipboard()
	if not ok_picker then
		return
	end

	picker.cliphist({
		confirm = function(p, item)
			p:close()
			if item then
				vim.schedule(function()
					local text = get_item_text(item)
					vim.fn.setreg("+", text)
					M.notify()
				end)
			end
		end,
	})
end

---Opens the clipboard history picker and inserts the selected item at the cursor.
---@return nil
function M.insert_clipboard()
	if not ok_picker then
		return
	end

	picker.cliphist({
		confirm = function(p, item)
			p:close()
			if item then
				vim.schedule(function()
					local text = get_item_text(item)
					local lines = vim.split(text, "\n", { plain = true })
					-- Remove trailing empty line if present (common when copying from text editors)
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
