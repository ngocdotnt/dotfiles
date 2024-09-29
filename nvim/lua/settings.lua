--stylua: ignore start


-- Global editor settings ===================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Option settings ==========================================================

vim.opt.breakindentopt      = "list:-1"
vim.opt.clipboard           = "unnamedplus"
vim.opt.conceallevel        = 2
vim.opt.cursorline          = true
vim.opt.confirm             = true
vim.opt.completeopt         = "menuone,noinsert"
vim.opt.expandtab           = true
vim.opt.fillchars           = { foldopen=" ", foldclose="", fold=" ", foldsep=" ", diff="╱", eob=" " }

-- Shell terminal settings
vim.opt.shell = vim.fn.executable "pwsh" and "pwsh" or "powershell"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- vim.opt.foldcolumn          = "auto"
vim.opt.foldexpr            = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel           = 99
vim.opt.foldmethod          = "expr"
vim.opt.foldnestmax         = 10
vim.opt.foldtext            = ""

vim.opt.formatoptions       = "jcroqlnt"
vim.opt.grepformat          = "%f:%l:%c:%m"
vim.opt.grepprg             = "rg --vimgrep"
vim.opt.inccommand          = "split"
vim.opt.listchars           = { tab="  ", trail="·", nbsp="␣" }
vim.opt.scrolloff           = 4
vim.opt.sessionoptions      = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.shiftround          = true
vim.opt.shiftwidth          = 2

vim.opt.shortmess:append({ S=true, W=true, I=true, c=true, C=true })

vim.opt.splitbelow          = true
vim.opt.splitright          = true
vim.opt.textwidth           = 78
-- vim.opt.timeoutlen       = 300
-- vim.opt.updatetime       = 250
vim.opt.virtualedit         = "block"
vim.opt.wildmode            = "longest:full,full"
vim.opt.winminwidth         = 5

--stylua: ignore end
