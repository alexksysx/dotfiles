return {
-- NvimTree
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
	"nvim-tree/nvim-web-devicons",
      },
      config = function()
	require("nvim-tree").setup {}
      end,
    },
-- Which key
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
	spec = {
	  { "<leader>f", group = "Telescope" },
	  { "<leader>l", group = "Line numbers" },
    { "<leader>b", group = "Buffers"}
	},
      },
      keys = {
	{
	  "<leader>",
	}
      },
    },
-- Telescope
    {
      "nvim-telescope/telescope.nvim", tag = "0.1.8",
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
-- catppuccin
    { 
      "catppuccin/nvim", 
      name = "catppuccin", 
      priority = 1000,
    },
-- lualine
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
	theme = "catppuccin",
	globalstatus = true,
      },
    },
-- Gitsigns
    {
      "lewis6991/gitsigns.nvim",
      event = "BufReadPre",
      opts = {
	signs = {
    	  add          = { text = '┃' },
    	  change       = { text = '┃' },
    	  delete       = { text = '_' },
    	  topdelete    = { text = '‾' },
    	  changedelete = { text = '~' },
    	  untracked    = { text = '┆' },
        },
        signs_staged = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      }
    },
-- TreeSitter
    {
      "nvim-treesitter/nvim-treesitter",
      event = { "BufReadPost", "BufNewFile" },
      cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
      build = ":TSUpdate",
      opts = {
        ensure_installed = {"lua", "c", "cpp", "markdown", "markdown_inline"},
	      highlight = {
          enable = true,
          use_languagetree = true,
        },
        indent = { enable = true },
      },
    },
-- Mason
    {
      "williamboman/mason.nvim",
      -- cmd = {"Mason", "MasonInstall", "MasonUpdate"},
      lazy = false,
    },
-- mason-lsp
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
    },
-- nvim-lsp
    {
      "neovim/nvim-lspconfig",
    },
-- load luasnips + cmp related in insert mode only
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        {
          -- snippet plugin
          "L3MON4D3/LuaSnip",
          dependencies = "rafamadriz/friendly-snippets",
          opts = { history = true, updateevents = "TextChanged,TextChangedI" },
          config = function(_, opts)
            require("luasnip").config.set_config(opts)
            require "extras.luasnip"
          end,
        },

        -- autopairing of (){}[] etc
        {
          "windwp/nvim-autopairs",
          opts = {
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt", "vim" },
          },
          config = function(_, opts)
            require("nvim-autopairs").setup(opts)

            -- setup cmp for autopairs
            local cmp_autopairs = require "nvim-autopairs.completion.cmp"
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
          end,
        },

        -- cmp sources plugins
        {
          "saadparwaiz1/cmp_luasnip",
          "hrsh7th/cmp-nvim-lua",
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
        },
      },
      opts = function()
        return require "extras.cmp"
      end,
    },
-- ZenMode
    {
      "folke/zen-mode.nvim",
      opts = {},
      cmd = { "ZenMode" },
    },
-- Twilight
    {
      "folke/twilight.nvim",
      opts = {},
      cmd = { "Twilight", "TwilightEnable", "TwilightDisable" }
    },
-- NEXT
}
