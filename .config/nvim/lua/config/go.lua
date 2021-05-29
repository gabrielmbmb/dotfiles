local g = vim.g

g.go_highlight_fields = 1
g.go_highlight_functions = 1
g.go_highlight_function_calls = 1
g.go_highlight_extra_types = 1
g.go_highlight_operators = 1

-- Format on save and importing
g.go_fmt_autosave = 1
g.go_fmt_command = 'goimports'

-- Lint on save
g.go_metalinter_command = 'golangci-lint'
g.go_metalinter_autosave = 1

-- Show var type info in status line
g.go_auto_type_info = 1
