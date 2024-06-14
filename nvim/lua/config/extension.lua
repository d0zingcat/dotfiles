function GetPath()
    vim.fn.setreg('+', vim.fn.getreg('%'))
end

function OpenFinder()
    local current_path = vim.fn.expand('%:p:h')
    vim.cmd('!open ' .. current_path)
end

vim.api.nvim_set_keymap('n', '<leader>of', ':lua OpenFinder()<CR>', { noremap = true, silent = true })
