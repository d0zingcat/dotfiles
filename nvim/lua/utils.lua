local cmd = vim.cmd
local o_s = vim.o
local map_key = vim.api.nvim_set_keymap
local g = vim.g
local api = vim.api
local fn = vim.fn
local ncmd = vim.api.nvim_command
local lsp = vim.lsp
local o, wo, bo = vim.o, vim.wo, vim.bo

local buffer = { o, bo }
local window = { o, wo }

local function opt(o, v, scopes)
    scopes = scopes or { o_s }
    for _, s in ipairs(scopes) do
        s[o] = v
    end
end

local function autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == 'string' then
        cmds = { cmds }
    end
    cmd('augroup ' .. group)
    if clear then
        cmd([[au!]])
    end
    for _, c in ipairs(cmds) do
        cmd('autocmd ' .. c)
    end
    cmd([[augroup END]])
end

local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    if type(modes) == 'string' then
        modes = { modes }
    end
    for _, mode in ipairs(modes) do
        map_key(mode, lhs, rhs, opts)
    end
end

local function set(opt, v, scopes)
    scopes = scopes or { o }
    for _, s in ipairs(scopes) do
        s[opt] = v
    end
end

return { opt = opt, autocmd = autocmd, map = map, set = set, ncmd = ncmd }
