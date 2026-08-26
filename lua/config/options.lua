local opt = vim.opt
opt.tabstop = 2
opt.shiftwidth = 2
opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
opt.cmdheight = 1 -- more space in the neovim command line for displaying messagesk
opt.cursorline = true -- highlight the current line
opt.softtabstop = 2
opt.expandtab = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = true

-- apperance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 10
opt.completeopt = "menuone,noinsert,noselect,fuzzy"

-- Configure winborder for floating windows (new in 0.11)
opt.winborder = "single"

-- Behaviour
opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.iskeyword:append("-")
opt.selection = "exclusive"
opt.mouse = "a"
opt.clipboard:append("unnamedplus")
opt.modifiable = true
opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block"
opt.encoding = "UTF-8"
opt.showmode = false
opt.jumpoptions = "stack,view"

-- folds
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99

