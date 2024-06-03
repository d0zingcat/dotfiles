local g = vim.g

-- vim-go
-- let g:go_code_completion_enabled = 1 -- Enable Autocompletion
--g['go_fmt_command'] = 'goimports' -- 格式化将默认的 gofmt 替换
g['go_autodetect_gopath'] = 1
g['go_list_type'] = 'quickfix'
g['go_version_warning'] = 1
g['go_highlight_types'] = 1
g['go_highlight_fields'] = 1
g['go_highlight_functions'] = 1
g['go_highlight_function_calls'] = 1
g['go_highlight_operators'] = 1
g['go_highlight_extra_types'] = 1
g['go_highlight_methods'] = 1
g['go_highlight_generate_tags'] = 1
g['godef_split'] = 2
--g['go_fmt_command'] = 'goimports'    " Run goimports along gofmt on each save
g['go_imports_mode'] = 'goimports'
g['go_imports_autosave'] = 0 -- do not auto import
g['go_auto_type_info'] = 1 -- automatically get signature/type info for object under cursor
