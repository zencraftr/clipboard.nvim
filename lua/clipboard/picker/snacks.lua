local M = {}

M.name = "snacks"

local config = require("clipboard.config")

---Call Snacks.picker populated with the clipboard history.
---@param on_select fun(text: string): nil Callback invoked with the selected clipboard entry
---@return nil
function M.pick(on_select)
	local entries = require("clipboard.source." .. config.opts.source).get_entries()

	require("snacks.picker").pick("ClipboardHistory", {
		title = "Clipboard History",
		layout = { preset = "default", preview = true },
		preview = "preview",

		items = entries,

		format = function(item, _)
			return {
				{ string.format("%d ", item.idx), "SnacksPickerIdx" },
				{ item.text, "SnacksPickerItem" },
			}
		end,

		confirm = function(picker, entry)
			picker:close()

			if entry and on_select then
				on_select(entry.text)
			end
		end,
	})
end

return M
