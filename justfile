# Install mini.test (mini.nvim's testing framework)
deps:
    mkdir -p deps
    git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim deps/mini.nvim

# Run all tests
test:
    nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

# Run a specific test file
test-file FILE:
    nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('{{FILE}}')"

act:
  act --quiet

