-- TODO: Add more pickers (e.g. telescope, fzf, etc.)
---@alias PickerProvider "snacks"
---@alias ClipboardSource "native" | "clipse"

---@class SnacksPickerItem
---@field data string | nil The clipboard item text
---@field text string The display text for the picker item

---@class NotificationConfig
---@field msg string The notification message to display when copying an entry from the clipboard
---@field clr string The notification message to display when clearing the clipboard history
---@field annote string The annotation (title) for the notification

---@class ClipboardConfig
---@field picker PickerProvider The picker provider to use
---@field notification boolean | NotificationConfig Notification config or boolean to enable defaults or disable
---@field source ClipboardSource The clipboard source to use

---@class NativeEntry
---@field text string The yanked text in Neovim
---@field timestamp number The unix timestamp when the text was yanked
---@field ft string	The filetype of the buffer the yanked text is from
