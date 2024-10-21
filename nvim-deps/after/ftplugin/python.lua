-- show line after desired maximum text width
vim.cmd('setlocal colorcolumn=89')

-- Indentation
vim.g.pyindent_open_paren = 'shiftwidth()'
vim.g.pyindent_continue = 'shiftwidth()'

-- mini.indentscope
vim.b.miniindentscope_config = { options = { border = 'top' } }
