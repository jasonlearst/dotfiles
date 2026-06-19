-- Neovim config -- a capable terminal editor, not an IDE.
-- Ported from ~/.vimrc; syntax + indentation use Neovim's built-ins
-- (regex `syntax on` + filetype indent, both on by default).
-- Plugins managed by lazy.nvim; commenting uses built-in gc (no plugin).

----------------------------------------------------------------------
-- Options (mirrors ~/.vimrc)
----------------------------------------------------------------------
local opt = vim.opt

opt.termguicolors = true            -- truecolor for lua themes
opt.laststatus = 2
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
-- Statusline (mode badge + file + fugitive branch + position)
-- Native; no plugin. Mode badge only colors the active window.
----------------------------------------------------------------------
local mode_map = {
  n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
  s = "SELECT", S = "S-LINE", c = "COMMAND", R = "REPLACE", t = "TERMINAL",
}
local mode_hl = {
  n = "StatusModeNormal", i = "StatusModeInsert", v = "StatusModeVisual",
  V = "StatusModeVisual", ["\22"] = "StatusModeVisual", R = "StatusModeReplace",
  c = "StatusModeCommand", t = "StatusModeTerminal",
}

function _G.statusline_mode()
  if tonumber(vim.g.statusline_winid) ~= vim.api.nvim_get_current_win() then
    return "    "                       -- inactive window: blank, no badge
  end
  local m = vim.fn.mode()
  return string.format("%%#%s# %s %%*", mode_hl[m] or "StatusModeNormal",
                       mode_map[m] or m:upper())
end

function _G.statusline_git()
  local head = vim.fn.exists("*FugitiveHead") == 1 and vim.fn.FugitiveHead() or ""
  return head ~= "" and ("  " .. head .. " ") or ""
end

opt.statusline = table.concat({
  "%{%v:lua.statusline_mode()%}",       -- colored mode badge (active window only)
  " %<%f%m%r%h%w",                       -- file + flags, truncate long paths first
  "%=",                                  -- split: the rest is right-aligned
  "%{v:lua.statusline_git()}",           -- git branch via fugitive
  "%y %l:%v %p%% %L ",                    -- filetype, line:col, percent, length
})

-- Nord-tinted mode colors, re-applied so they survive :colorscheme reloads.
local function set_status_hl()
  local fg, modes = "#2e3440", {
    StatusModeNormal = "#81a1c1", StatusModeInsert = "#a3be8c",
    StatusModeVisual = "#b48ead", StatusModeReplace = "#bf616a",
    StatusModeCommand = "#ebcb8b", StatusModeTerminal = "#8fbcbb",
  }
  for name, bg in pairs(modes) do
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = true })
  end
end
set_status_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_status_hl })

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

  -- indent guides (replaces vim-indent-guides)
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- correct filetype/highlighting for chezmoi source files (dot_*, *.tmpl)
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },

  -- carried over unchanged from ~/.vimrc
  { "tpope/vim-fugitive" },
  { "christoomey/vim-tmux-navigator" },
}, {
  change_detection = { notify = false },
})
