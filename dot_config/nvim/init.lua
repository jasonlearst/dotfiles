-- Neovim config -- a capable terminal editor, not an IDE.
-- Ported from ~/.vimrc; the upgrade over Vim is tree-sitter syntax/indent.
-- Plugins managed by lazy.nvim; commenting uses built-in gc (no plugin).

----------------------------------------------------------------------
-- Options (mirrors ~/.vimrc)
----------------------------------------------------------------------
local opt = vim.opt

opt.termguicolors = true            -- truecolor for lua themes
opt.laststatus = 2
opt.statusline = "%F%m%r%h%w [TYPE=%Y] [POS=%04l,%04v][%p%%] [LEN=%L]"
opt.backup = false
opt.writebackup = false
opt.showmatch = true                -- better bracket support
opt.shortmess:append("atI")         -- quieter messages, no intro
opt.relativenumber = true
opt.clipboard = "unnamed"           -- share system clipboard
opt.scrolloff = 10
opt.omnifunc = "syntaxcomplete#Complete"

-- Text formatting / layout
opt.formatoptions = "tcrqn"
opt.autoindent = true
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.expandtab = true                -- no tabs please
opt.wrap = false
opt.smarttab = true

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Move swap directory to tmp
opt.directory = "/tmp"

----------------------------------------------------------------------
-- Filetype rules (au BufNewFile,BufRead ... in ~/.vimrc)
----------------------------------------------------------------------
vim.filetype.add({
  extension = {
    kon = "kon",                    -- organi .kon highlighting
    A66 = "pic",                    -- A66 assembler files
  },
  pattern = {
    [".*wiki%.vi.*"] = "moin",      -- wiki highlighting
  },
})

----------------------------------------------------------------------
-- Key remappings (mirrors ~/.vimrc)
-- C-h/j/k/l pane navigation is provided by vim-tmux-navigator below.
----------------------------------------------------------------------
vim.keymap.set("n", "<C-Tab>", "<C-PageDown>", { silent = true })
vim.keymap.set("n", "<C-S-Tab>", "<C-PageUp>", { silent = true })

-- Leader-d / Leader-f insert current date / time
vim.keymap.set("i", "<leader>d", "<C-R>=strftime('%Y-%m-%d')<CR>")
vim.keymap.set("i", "<leader>f", "<C-R>=strftime('%H:%M:%S')<CR>")

-- Save with sudo
vim.keymap.set("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")

----------------------------------------------------------------------
-- Plugins (lazy.nvim)
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- nord colorscheme (replaces fork-nord-vim)
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({})
      pcall(vim.cmd.colorscheme, "nord")
    end,
  },

  -- tree-sitter: accurate syntax + indentation (replaces vim-polyglot)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "cpp", "css", "dockerfile", "go", "html", "json",
          "lua", "make", "markdown", "markdown_inline", "python", "rust",
          "toml", "typescript", "vim", "vimdoc", "yaml",
        },
        auto_install = true,
        highlight = { enable = true },
        -- treesitter's yaml indenter won't nest after a bare 'key:' mapping;
        -- nvim's bundled yaml indentexpr does (and is the correct one, not
        -- the buggy polyglot copy), so let it handle yaml.
        indent = { enable = true, disable = { "yaml" } },
      })
    end,
  },

  -- indent guides (replaces vim-indent-guides)
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- carried over unchanged from ~/.vimrc
  { "tpope/vim-fugitive" },
  { "christoomey/vim-tmux-navigator" },
  { "ervandew/supertab" },
}, {
  change_detection = { notify = false },
})
