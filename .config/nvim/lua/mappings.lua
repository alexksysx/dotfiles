local map = vim.keymap.set
-- comment, slash(/) in neovim is underscore(_) 
map("n", "<C-_>", "gcc", { remap = true })
map("v", "<C-_>", "gc", { remap = true })
-- map NvimTree
map("n", "<Leader>e", "<cmd>NvimTreeToggle<CR>", {desc = "nvimtree toggle"})
-- map Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Telescope find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Telescope live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Telescope buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Telescope help tags' })
-- lines
map("n", "<leader>ln", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>lr", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
-- windows movement
map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })
-- buffers
map('n', '<leader>bl', '<cmd>Telescope buffers<cr>', { desc = 'Telescope buffers' })
map('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'Create new buffer' })
-- splits
map('n', '<leader>s', '<cmd>split<cr>', { desc = 'Horizontal split' })
map('n', '<leader>v', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
-- ZenMode toggle
map("n", "<Leader>z", "<cmd>ZenMode<CR>", {desc = "ZenMode toggle"})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local function opts(desc)
      return { buffer = ev.buf, desc = "LSP: " .. desc }
    end

    map('n', 'gD', vim.lsp.buf.declaration, opts "Go to declaration")
    map('n', 'gd', vim.lsp.buf.definition, opts "Go to definition")
    map('n', '<C-b>', vim.lsp.buf.definition, opts "Go to definition")
    map('n', '<C-q>', vim.lsp.buf.hover, opts "Information about symbol")
    map('n', 'gi', vim.lsp.buf.implementation, opts "Go to implementation")
    -- map('n', '<C-k>', vim.lsp.buf.signature_help, opts "Signature of symbol")
    -- map('i', '<C-k>', vim.lsp.buf.signature_help, opts "Signature of symbol")
    map('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
    map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
    map('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts "List workspace folders")
    map('n', '<space>D', vim.lsp.buf.type_definition, opts "Go to type definition")
    map('n', '<space>rn', vim.lsp.buf.rename, opts "Rename file")
    map({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts "Code actions")
    map('n', 'gr', vim.lsp.buf.references, opts "List references to the symbol")
   map('n', '<leader>fr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true, desc = "LSP: List references" })
    map('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts "Format")
  end,
})
