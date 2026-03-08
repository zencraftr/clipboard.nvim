<div align="center">

# 📋 `clipboard.nvim`

</div>


<div align="center">

[![Lua Type Check](https://github.com/zencraftr/clipboard.nvim/actions/workflows/typecheck.yml/badge.svg?branch=main)](https://github.com/zencraftr/clipboard.nvim/actions/workflows/typecheck.yml)
[![Test](https://github.com/zencraftr/clipboard.nvim/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/zencraftr/clipboard.nvim/actions/workflows/test.yml)

</div>

Lightweight clipboard history manager for Neovim with a floating picker and quick paste support from the clipboard history. 

![Clipboard Picker Preview](https://github.com/zencraftr/clipboard.nvim/blob/main/assets/preview.png)

## ✨ Features

- 💾 Yank an entry from the clipboard history to your clipboard, ready to be pasted.
- ✏️ Insert an entry directly from the clipboard history directly to the current buffer. 
- 🔔 Customise or disable the notification when you copy an entry from the clipboard. 

## ⚡ Requirements 

- **Neovim** >= 0.9.4, see [`snacks.nvim` requirements](https://github.com/folke/snacks.nvim/?tab=readme-ov-file#%EF%B8%8F-requirements).
- **[clipse](https://github.com/savedra1/clipse)**, a configurable TUI clipboard manager for Unix.

## 📦 Installation 

Install the plugin with your package manager:

### 💤 [lazy.nvim](https://github.com/folke/lazy.nvim)

> [!important]
> This plugin requires [Snacks](https://github.com/folke/snacks.nvim) for the clipboard history picker.

> [!tip]
> Run `:checkhealth clipboard` to verify all dependencies are installed and configured correctly.

```lua
{
    "zencraftr/clipboard.nvim",

    dependencies = {
        "folke/snacks.nvim"
    },

    opts = {
        -- Your configuration comes here; or leave it empty to use the default options.
    },

	keys = {
		{ "<leader>yy", "<cmd>ClipboardHistory<cr>", desc = "Yank history to clipboard" },
		{ "<leader>yi", "<cmd>ClipboardInsert<cr>", desc = "Insert clipboard history" },
	},
}
```

> [!caution]
> `clipse` is an external executable, and it's the user's responsibility to ensure it runs while using this plugin.
> 

## ⚙️ Configuration 

Below is the schema of the possible options to customise `clipboard.nvim`.

<details><summary>Default Options</summary>

<!-- config:start -->

```lua
{
	-- Clipboard provider ("clipse" is currently the only supported option)
	source = "clipse",

	-- Picker provider ("snacks" is currently the only supported option)
	picker = "snacks",

	-- Possible values for notification:
	-- false                Disable notifications
	-- true                 Use the default message and annotation
	-- { msg, annote }      Define a custom message and annotation
	notification = {
		msg = "Copied to clipboard",
		annote = "clipboard",
	},
}
```

<!-- config:end -->

</details>

