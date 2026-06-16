-- ====================================================================
-- BASIC SETUP
-- ====================================================================

vim.env.CC = "gcc"
vim.env.CXX = "g++"

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true           -- easier vertical motion
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.list = true                     -- show whitespace characters
vim.o.listchars = 'tab:» ,trail:·'   -- especially useful in GDScript

vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode with jj' })
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle file tree' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Diagnostics navigation
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- ====================================================================
-- GODOT FILETYPE + INDENT
-- ====================================================================

vim.filetype.add({
  extension = {
    gd = "gdscript",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gdscript",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- ====================================================================
-- LAZY INSTALL
-- ====================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- ====================================================================
-- PLUGINS
-- ====================================================================

require('lazy').setup({

  -- ========================
  -- COMPLETION (Kickstart)
  -- ========================
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        opts = {},
      },
    },
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' }, -- Enter confirms completion, falls back to newline
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' }, -- added buffer source
      },
      snippets = {
        preset = 'luasnip',
      },
    },
  },

  -- ========================
  -- LSP (MODERN API)
  -- ========================
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy', -- defer loading the LSP stack instead of loading on every startup
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      -- Requires Neovim 0.11+
      vim.lsp.config("gdscript", {
        cmd = { "nc", "localhost", "6005" },
        filetypes = { "gdscript" }, -- "gd" removed: vim.filetype.add already maps .gd → gdscript
        root_dir = vim.fs.root(0, "project.godot"),
      })

      vim.lsp.enable("gdscript")
      vim.lsp.enable("pyright")  -- run :MasonInstall pyright if not already installed
    end,
  },

  -- ========================
  -- TREESITTER
  -- ========================
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.config').setup({  -- fixed: was .config, should be .configs
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "bash",
          "c",
          "diff",
          "markdown",
          "markdown_inline",
          "gdscript",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ========================
  -- FUZZY FINDER
  -- ========================
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep project' },
    },
  },

  -- ========================
  -- WHICH-KEY
  -- ========================
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- ========================
  -- FILE TREE
  -- ========================
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree', -- lazy-load on command instead of always loading at startup
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },

  -- ========================
  -- THEME
  -- ========================
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

}, {})

-- ====================================================================
-- SMALL QoL
-- ====================================================================

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
})