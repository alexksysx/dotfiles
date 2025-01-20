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
