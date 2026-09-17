return {
  {
    'nvim-mini/mini.nvim',
    version = '*',
    config = function()
      require('mini.surround').setup()
      require('mini.icons').setup({
        extension = {
          -- ["clang"] = { glyph = "", hl = "MiniIconsAzure" },
        },

        file = {
          [".clangd"]       = { glyph = "", hl = "MiniIconsAzure" },
          [".clang-format"] = { glyph = "", hl = "MiniIconsAzure" },
          [".gitignore"]    = { glyph = "", hl = "MiniIconsOrange" },
        },

        directory = {
          [".git"]          = { glyph = "", hl = "MiniIconsOrange" },
          -- ["src"] = { glyph = "", hl = "MiniIconsGrey" },
        },
      })
    end
  },
}
