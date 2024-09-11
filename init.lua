-- Options {{{
vim.opt.number = true -- enable line numbers
vim.wo.relativenumber = true -- enable relative line numbers
vim.opt.mouse = 'a' -- enable mouse support in all modes
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.smartcase = true -- respect case with uppercase letters
vim.opt.hlsearch = true -- highlight all search matches
vim.opt.incsearch = true -- incremental search
vim.opt.wrap = true -- wrap long lines
vim.opt.breakindent = true -- wrap long lines at indentation
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.tabstop = 2 -- set tab width to 2 spaces
vim.opt.shiftwidth = 2 -- set indentation level to 2 spaces
vim.opt.smartindent = true
vim.opt.clipboard = 'unnamedplus' -- access system clipboard
vim.opt.so = 7 -- set scroll offset to 7
vim.opt.showmode = false -- disable mode display
vim.opt.iskeyword:append '-' -- include - in keywords
vim.opt.foldmethod = 'marker'
vim.g.mapleader = ' ' -- set the leader key
-- }}}

-- Keymaps {{{
-- key map to clear search highlighting
vim.keymap.set('n', '<leader><space>', ':nohlsearch<cr>')

-- diagnostic keybindings
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- key map to manage buffers
vim.keymap.set('n', '<leader>bn', ':bnext<cr>')
vim.keymap.set('n', '<leader>bp', ':bprevious<cr>')
vim.keymap.set('n', '<leader>bd', ':bdelete<cr>')

-- key map for formatting
vim.keymap.set('n', '<leader>p', function()
  require('conform').format { timeout_ms = 3000 }
end)
vim.keymap.set('n', '<leader>rp', ':silent %!prettier --stdin-filepath %<cr>')

-- key map fro neo tree
vim.keymap.set('n', '<leader>l', function()
  require('neo-tree.command').execute({ toggle = true, dir = vim.uv.cwd() })
end)

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- key maps during lsp session
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>rr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
end
-- }}}

-- LazyVIM {{{
-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- setup plugins
require('lazy').setup {
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000, opts = {} },
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { 'nvim-telescope/telescope.nvim', tag = '0.1.4', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'onsails/lspkind.nvim' },
  { 'numToStr/Comment.nvim', opts = {}, lazy = false },
  { 'tpope/vim-surround' },
  { 'windwp/nvim-ts-autotag' },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
  },

  -- lsp
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'VonHeikemen/lsp-zero.nvim', branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'tikhomirov/vim-glsl' },
  { 'stevearc/conform.nvim' },

  -- autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-nvim-lua' },
  { 'L3MON4D3/LuaSnip' },
}
-- }}}

-- Setup color theme {{{
require('tokyonight').setup {
  style = 'storm',
  transparent = true,
}

vim.cmd [[colorscheme tokyonight]]
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
--- }}}

-- Setup comment {{{
require('Comment').setup()
-- }}}

-- Setup ts autotag {{{
require('nvim-ts-autotag').setup()
-- }}}

-- Setup Lualine {{{
require('lualine').setup {
  options = {
    theme = 'tokyonight',
  },
  tabline = {
    lualine_a = { 'buffers' },
    lualine_z = { 'tabs' },
  },
  sections = {
    lualine_b = { 'branch', 'diff' },
    lualine_c = { 'diagnostics' },
    lualine_x = { 'fileformat' },
    lualine_y = { 'filetype' },
    lualine_z = { 'location' },
  },
}
-- }}}

-- Setup lsp {{{
local lsp = require 'lsp-zero'
lsp.on_attach(on_attach)

lsp.set_sign_icons {
  error = '󰅚', -- x000f015a
  warn = '󰀪', -- x000f002a
  info = '󰋽', -- x000f02fd
  hint = '󰌶', -- x000f0336
}

lsp.setup()

local function lua()
  require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
end

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = {
    'lua_ls',
    'clangd',
  },
  handlers = {
    lsp.default_setup,
    lua_ls = lua,
  },
}
-- }}}

-- Setup formatting {{{
local function contains(array, value)
  for _, v in ipairs(array) do
    if v == value then
      return true
    end
  end
  return false
end

-- inject the formatters installed through mason into conform
local packages = require('mason-registry').get_installed_packages()
local formatters_by_ft = {}

for _, package in ipairs(packages) do
  if contains(package.spec.categories, 'Formatter') then
    for _, lang in ipairs(package.spec.languages) do
      local lang_lower = string.lower(lang)
      if not formatters_by_ft[lang_lower] then
        formatters_by_ft[lang_lower] = {}
      end

      table.insert(formatters_by_ft[lang_lower], package.name)
    end
  end
end

for _, formatters in pairs(formatters_by_ft) do
  if #formatters > 1 then
    formatters['stop_after_first'] = true
  end
end

require('conform').setup {
  formatters_by_ft = formatters_by_ft,
}
-- }}}

-- Setup telescope {{{
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>fa', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '-L',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
    file_ignore_patterns = {
      'node_modules',
      'vendor',
    },
  },

  pickers = {
    find_files = {
      hidden = true,
    },
  },
}
--- }}}

-- Setup autocompletion {{{
local cmp = require 'cmp'

cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  },
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-;>'] = cmp.mapping.complete(),
  },
  formatting = {
    format = require('lspkind').cmp_format {
      menu = {
        buffer = '[Buffer]',
        nvim_lsp = '[LSP]',
        luasnip = '[LuaSnip]',
        nvim_lua = '[Lua]',
        latex_symbols = '[Latex]',
      },
    },
  },
}
-- }}}

-- Setup treesitter {{{
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'haskell',
    'javascript',
    'typescript',
    'c',
    'cpp',
    'lua',
    'vim',
    'vimdoc',
    'query',
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}
-- }}}
