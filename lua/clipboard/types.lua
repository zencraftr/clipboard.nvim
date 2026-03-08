-- TODO: Add more pickers (e.g. telescope, fzf, etc.)
---@alias PickerProvider "snacks"
---@alias ClipboardSource "clipse"

---@class SnacksPickerItem
---@field data string | nil The clipboard item text
---@field text string The display text for the picker item

---@class NotificationConfig
---@field msg string The notification message to display
---@field annote string The annotation (title) for the notification

---@class Config
---@field picker PickerProvider The picker provider to use
---@field notification boolean | NotificationConfig Notification config or boolean to enable defaults or disable
---@field source ClipboardSource The clipboard source to use
