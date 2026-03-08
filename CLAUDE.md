# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

clipboard.nvim is a Neovim plugin that provides clipboard history management with a floating picker UI. It integrates with external clipboard history managers (clipse) and uses snacks.nvim for the picker interface.

## Development Commands

```bash
# Install test dependencies (mini.nvim)
just deps

# Run all tests
just test

# Run a specific test file
just test-file tests/test_config.lua

# Run CI locally (tests + formatting)
just act
```

Tests use mini.test from mini.nvim. The test framework runs headless Neovim instances.

## Architecture

```
lua/clipboard/
├── init.lua      # Entry point, creates user commands (ClipboardYank, ClipboardInsert)
├── config.lua    # Configuration management with defaults
├── core.lua      # Core logic: notify(), yank_clipboard(), insert_clipboard()
├── types.lua     # LuaLS type annotations
├── health.lua    # :checkhealth clipboard integration
├── picker/       # Picker implementations (snacks.lua)
└── source/       # Clipboard source adapters (clipse.lua)
```

**Data flow**: User command → core.lua → picker (snacks) → source adapter → clipboard history

**Extensibility points**:
- `picker/` - Add new picker providers (currently only snacks)
- `source/` - Add new clipboard source adapters (currently clipse)

## Type Checking

The project uses LuaLS annotations for type checking. CI runs `lua-typecheck-action` against `lua/` using `.luarc.json`.

## Key Dependencies

- **Runtime**: snacks.nvim (picker UI), external clipboard manager (clipse)
- **Testing**: mini.nvim (mini.test framework)
