<div align="center">

# 📋 `clipboard.nvim`

</div>


<div align="center">

[![Lua Type Check](https://github.com/zencraftr/clipboard.nvim/actions/workflows/typecheck.yml/badge.svg?branch=main)](https://github.com/zencraftr/clipboard.nvim/actions/workflows/typecheck.yml)

Lightweight clipboard history manager for Neovim with a floating picker and quick paste support from the clipboard history. 

## ✨ Features

<!-- toc:start -->

| Description | Progress |
| ----------- | :------: |
| Yank a clipboard history entry to the clipboard, ready to be pasted. | ✅ |
| Insert an entry directly into the buffer last buffer. | ✅ | 

<!-- toc:end -->

## ⚡ Requirements 

- **Neovim** >= 0.9.4, see [`snacks.nvim` requirements](https://github.com/folke/snacks.nvim/?tab=readme-ov-file#%EF%B8%8F-requirements).
- **[cliphist](https://github.com/sentriz/cliphist)**, external clipboard history manager.

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
> `cliphist` is an external executable. It is the user's responsibility to ensure that it is running while using this plugin. We recommend configuring `cliphist` to run as a **daemon** at system startup.  
> 
> **Note:** `cliphist` is Wayland specific, and wouldn't work on X11.

## ⚙️ Configuration 

Below is the schema of the possible options to customise `clipboard.nvim`.

<details><summary>Default Options</summary>

<!-- config:start -->

```lua
{
    -- Picker provider ("snacks" is currently the only supported option)
    picker = "snacks",

    -- Possible values for notification:
    -- false                disable notifications
    -- true                 use default msg and title
    -- { msg, annote }       custom message and title
    notification = {
        msg = "Copied to clipboard"
        annote = "Clipboard"
    }
}
```

<!-- config:end -->

</details>

## 🔗 Links

- **[cliphist](https://github.com/sentriz/cliphist)** — Clipboard history manager that this plugin integrates with.
- **[snacks.nvim](https://github.com/folke/snacks.nvim)** — Neovim plugin providing the picker UI.


