# AGENTS.md

clipboard.nvim provides clipboard history management with a floating picker UI. It integrates with external clipboard managers (clipse) and uses snacks.nvim for the picker interface.

## Development Commands

```bash
# Install mini.nvim (test dependency)
just deps

# Run all tests
just test

# Run a specific test file
just test-file tests/test_config.lua
```

### CI Workflows

- **test.yml**: Runs `just test` on Neovim latest stable
- **typecheck.yml**: Runs `lua-typecheck-action` against `lua/` using `.luarc.json`

## Code Style

### Formatting

From `.editorconfig`:
- **Indentation**: Tabs (4 spaces)
- **Line endings**: LF
- **Charset**: UTF-8
- **Trailing whitespace**: Trimmed
- **Final newline**: Required

### LuaLS Type Annotations

All modules must have LuaLS annotations. Types go in `lua/clipboard/types.lua`.

```lua
---@param name type Description
---@return type Description
---@class ClassName
---@field field type Description
---@alias AliasName "value1" | "value2"
```

Globals recognized by type checker (`.luarc.json`): `vim`, `MiniTest`

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Modules | `snake_case.lua` | `clipboard/core.lua` |
| Functions | `snake_case` | `yank_clipboard()` |
| Private helpers | `_snake_case` | `_notify()`, `_load()` |
| Types/Classes | `PascalCase` | `ClipboardConfig`, `NativeEntry` |
| Module exports | `M` | `local M = {}` |

### File Structure

```
lua/clipboard/
├── init.lua      # Entry point, setup(), user commands
├── config.lua    # Configuration with defaults
├── core.lua      # Core logic (yank, insert, clear, notify)
├── types.lua     # LuaLS type definitions
├── health.lua    # :checkhealth integration
├── utils.lua     # Utility functions
├── picker/       # Picker provider implementations
│   └── snacks.lua
└── source/       # Clipboard source adapters
    ├── native.lua
    └── clipse.lua
```

### Module Pattern

```lua
local M = {}

local config = require("clipboard.config")

---@param custom_opts ClipboardConfig
---@return nil
function M.setup(custom_opts)
    -- implementation
end

return M
```

### Import Pattern

- Use `require()` at module top-level
- Avoid circular dependencies
- Group imports: external (vim), then internal

### Error Handling

- Use `pcall` for external operations (file I/O, JSON)
- Return early on errors; never throw exceptions

```lua
local ok, result = pcall(vim.json.decode, raw)
if not ok then return {} end
```

## Testing

Tests use **mini.test** from mini.nvim with child Neovim process model. Always use `tests/helper.lua`.

### Test Helpers

- `child.clean()` - Standard clean, loads Config, Core, Health
- `child.clean_native()` - Mocks `vim.fn.stdpath("data")` for native source tests
- `child.mock_clipse_dir()` / `child.restore_clipse_dir()` - Mocks clipse config
- `child.check_health()` - Returns `{ ok, warn, error }` arrays
- `child.notify()` / `child.get_notifications()` - Spy on `vim.notify`
- `child.mock_snacks_picker()` - Mocks snacks.picker module

### Test Structure

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

T["feature"] = MiniTest.new_set()
T["feature"]["test description"] = function()
    equal(actual, expected)
end

return T
```

### Common Patterns

**Mocking stdpath:**
```lua
hooks = {
    pre_case = child.clean_native,
    post_case = child.restore_native_dir,
}
```

**Testing notifications:**
```lua
child.notify()
-- ... action ...
equal(#child.get_notifications(), 1)
```

**Stubbing executables:**
```lua
child.lua([[vim.fn.executable = function(cmd)
    return cmd == "clipse" and 1 or 0
end]])
```

## Dependencies

- **Runtime**: snacks.nvim, external clipboard manager (clipse)
- **Testing**: mini.nvim (mini.test framework)

## Extensibility

- **Picker providers**: Add to `lua/clipboard/picker/` implementing `pick(callback)`
- **Clipboard sources**: Add to `lua/clipboard/source/` with `name`, `setup()`, `get_entries()`, `clear()`
