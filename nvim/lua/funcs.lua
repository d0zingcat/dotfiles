local fn = vim.fn

function GetPath()
    fn.setreg('+', fn.getreg('%'))
end
