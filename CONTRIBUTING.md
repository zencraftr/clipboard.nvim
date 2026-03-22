# Contributing to clipboard.nvim

## 🔰 Getting Started

To get started contributing to this plugin, follow the steps below:

1. Fork the plugin's repository, see more in [GitHub Docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo)
2. Clone your fork: `git clone https://github.com/<your-username>/clipboard.nvim.git`
3. Install dependencies: `just mini` to install [`mini.nvim`](https://github.com/nvim-mini/mini.nvim)
4. Start contributing and making your changes

## ▶️ Just

This repository uses [`just`](https://github.com/casey/just) to simplify the contributer's weight when contributing to the plugin. If you don't have just installed, or you prefer to run the commands yourself, you can inspect the `./justfile` to understand what the just recipes do.

```bash
# Install mini.nvim
just mini

# Run tests
just test

# Run a specific test file
just test-file tests/test_config.lua
```

## 👗 Code Style

The code style for this plugin has been define in the `./.editorconfig` file for tabs, end of line, etc. 

As for naming and coding conventions, see the point below:

- **LuaLS annotations**: Required for all modules (see `lua/clipboard/types.lua`)
- **Naming**: `snake_case` for functions/modules, `PascalCase` for types
- **Module exports**: Use `local M = {}` pattern
- Private helpers prefixed with `_`
- Use `pcall` for external operations (file I/O, JSON)
- Return early on errors; never throw exceptions

## Testing

Tests use [`mini.test`](https://github.com/nvim-mini/mini.test) with child Neovim process model. If you are not familiar with the `mini.test` process, we recommend follwing the [TESTING.md](https://nvim-mini.org/mini.nvim/TESTING) introduction. 
Also, you can use the test files are present to get a better understanding how `mini.tests` is used for testing this plugin.

Always use `tests/helper.lua`.

```lua
local helpers = require("tests.helper")
local equal = MiniTest.expect.equality
local child = helpers.new_child_neovim()

local T = MiniTest.new_set({
    hooks = {
        pre_once = child.start,
        pre_case = child.clean,
        post_once = child.stop,
    },
})

T["feature"]["test description"] = function()
    equal(actual, expected)
end

return T
```

## Pull Request Process

Before opening a PR, you should ensure that the checklist below passes.

- [ ] Ensure all tests pass (`just test`)
- [ ] Run type checking (`just ci`)
- [ ] Update documentation if needed
- [ ] Keep changes focused and atomic

## Extending the Plugin

- **Picker providers**: Add to `lua/clipboard/picker/` implementing `pick(callback)`
- **Clipboard sources**: Add to `lua/clipboard/source/` with `name`, `setup()`, `get_entries()`, `clear()`
