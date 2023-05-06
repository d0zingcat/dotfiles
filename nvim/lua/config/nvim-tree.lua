local function open_nvim_tree(data)
    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    if directory then
        -- create a new, empty buffer
        vim.cmd.enew()

        -- wipe the directory buffer
        vim.cmd.bw(data.buf)

        -- change to the directory
        vim.cmd.cd(data.file)

        -- open the tree
        require("nvim-tree.api").tree.open()
    end

    if real_file or no_name then
        -- open the tree, find the file but don't focus it
        require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
    end

end

--- autocmd with callbacks
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
    pattern = "NvimTree_*",
    callback = function()
        local layout = vim.api.nvim_call_function("winlayout", {})
        if layout[1] == "leaf" and
            vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and
            layout[3] == nil then vim.cmd("confirm quit") end
    end
})

local function on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)
    -- Mappings migrated from view.mappings.list
    -- You will need to insert "your code goes here" for any mappings with a custom action_cb
    vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', 'P', function()
        local node = api.tree.get_node_under_cursor()
        print(node.absolute_path)
    end, opts('Print Node Path'))
end

require('nvim-tree').setup({
    view = {
        width = 35,
        side = 'left',
    },
    renderer = {
        highlight_opened_files = '1',
    },
    diagnostics = {
        enable = true,
        icons = {
            error = '',
            warning = '',
            info = '',
            hint = '',
        },
    },
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    filters = {
        custom = {
            '.git$'
        },
    },
    hijack_netrw = true,
    update_cwd = true,
    on_attach = on_attach,
})

-- map('n', '<leader>te', ':NvimTreeToggle<CR>')

-- vim.cmd([[
-- autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
-- augroup nvimtree
--   autocmd VimEnter * lua require('nvim-tree').toggle(false, true)
-- augroup END
-- ]])
