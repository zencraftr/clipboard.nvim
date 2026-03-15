local M = {}

M.name = "snacks"

local config = require("clipboard.config")

---@param on_select fun(text: string): nil Callback invoked with the selected clipboard entry
function M.pick(on_select)
	local entries = require("clipboard.source." .. config.opts.source).get_entries()

	require("snacks.picker").pick("clipse_history", {
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
