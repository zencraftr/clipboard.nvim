---
name: Bug report
about: Report a bug or unexpected behavior in clipboard.nvim
title: ''
labels: bug
assignees: zencraftr

---

**Before submitting**, run `:checkhealth clipboard` and include the output in the section below.

## ✏️ Describe the bug

A clear and concise description of what the bug is.

## 🚶Steps to reproduce

1. Copy some text
2. Open Neovim and run `:ClipboardHistory` / `:ClipboardInsert`
3. ...
4. See error

## ✅ Expected behavior

A clear and concise description of what you expected to happen.

## 🩺 Healthcheck

Run `:checkhealth clipboard` and paste the output here.

```
Output here
```

## ⚙️ Configuration

```lua
{
    "zencraftr/clipboard.nvim",
    dependencies = {
        "folke/snacks.nvim"
    },
    opts = {
        picker = "snacks",
    },
    keys = {
	{ "<leader>yy", "<cmd>ClipboardHistory<cr>", desc = "Yank history to clipboard" },
	{ "<leader>yi", "<cmd>ClipboardInsert<cr>", desc = "Insert clipboard history" },
   },
}
```

##  ❌ Error messages

Paste any errors from :messages or Neovim's output. Leave blank if none.

## 🏠  Environment

Local  information | Details
-- | --
Neovim version (`nvim --version`) | e.g. NVIM v0.10.3
Is `cliphist` running? | Yes, as a command \ Yes, as a daemon \ No
OS | Linux (Wayland) \ Linux (X11) \ MacOS \ Windows (WSL)
Linux distro (if applicable) | e.g. NixOS 26.05.20260304.80bdc1e (Yarara)

## 🖼️ Screenshots or recordings

If applicable, add screenshots or a screen recording to help explain your problem.

## ✏️ Additional context

Any other context, workarounds you've tried, or related issues.
