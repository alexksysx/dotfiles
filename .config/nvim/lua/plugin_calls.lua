-- Plugins loadings if needed
-- Catppuccin
vim.cmd.colorscheme("catppuccin-macchiato")
--lualine
vim.o.laststatus = 3
-- Mason
-- require("mason").setup()
-- require("mason-lspconfig").setup({
--   automatic_enable = true,
--   ensure_installed = { "lua_ls" }
-- })

require("bufferline").setup {
  options = {
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        separator = true
      },
      {
        filetype = 'snacks_layout_box',
      }
    },
    hover = {
      enabled = true,
      delay = 200,
      reveal = { 'close' }
    },
    separator_style = "slant",
    diagnostics = "nvim_lsp",

    diagnostics_update_on_event = true,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
            or (e == "warning" and " " or " ")
        s = s .. n .. sym
      end
      return s
    end,
    middle_mouse_command = "bdelete %d",
  }
}

require('mini.surround').setup()
