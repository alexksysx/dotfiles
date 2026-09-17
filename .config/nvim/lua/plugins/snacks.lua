return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Telescope" },
        { "<leader>l", group = "Line numbers" },
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code actions" },
        { "<leader>g", group = "Git" },
        { "<leader>s", group = "Splits" },
        { "<leader>i", group = "Task Tracker" },
      },
    },
    keys = {
      {
        "<leader>",
      }
    },
  },
  {
    "folke/snacks.nvim",
    dependencies = 'nvim-tree/nvim-web-devicons',
    priority = 1000,
    lazy = false,
    opts = {
      indent = {
        enabled = false,
        indent = {
          enabled = false
        }
      },
      dashboard = {
        enabled = true,
        example = "compact_files",
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            -- { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          }
        }
      },
      zen = {
        toggles = {
          dim = false,
          git_signs = true,
          -- mini_diff_signs = false,
          diagnostics = true,
          inlay_hints = true,
        },
        show = {
          statusline = true, -- can only be shown when using the global statusline
          tabline = false,
        },
        win = {
          backdrop = {
            transparent = false,
            blend = 99
          }
        }
      },
      input = {
        enabled = true,
      },
      scratch = {
        enabled = true,
      },
      styles = {
        zen = {
          width = 140
        }
      },
      explorer = {},
      picker = {
        sources = {
          explorer = {
          }
        }
      },
    }
  },
}
