local opt = vim.opt

-- indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = true

-- appearance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.cursorline = true
opt.scrolloff = 10
opt.completeopt = "menuone,noinsert,noselect,fuzzy"
opt.winborder = "single" -- floating windows border
opt.showmode = false
opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block"

-- behaviour
opt.clipboard = "unnamedplus" -- use the system clipboard
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.iskeyword:append("-")
opt.selection = "exclusive"
opt.mouse = "a"
opt.jumpoptions = "stack,view"
-- Do not store fold state in sessions: treesitter folds do not exist yet when
-- a session is sourced, so `normal! zo` lines fail with E490.
opt.sessionoptions:remove("folds")

-- folds (treesitter, built into Neovim)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
