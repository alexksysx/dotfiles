-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
require("options")
-- Map settings
require("mappings")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

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

vim.opt.termguicolors = true
require("bufferline").setup {
  options = {
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        separator = true
      },
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

require("extras.lsp")
