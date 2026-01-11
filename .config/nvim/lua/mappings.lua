local map = vim.keymap.set
-- comment, slash(/) in neovim is underscore(_)
map("n", "<C-_>", "gcc", { remap = true })
map("v", "<C-_>", "gc", { remap = true })

-- map Snacks.explorer
map("n", "<Leader>e", function() Snacks.explorer.open({ hidden = true, ignored = true }) end,
  { desc = "nvimtree toggle" })

-- map Snacks.picker
map('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Smart' })
map('n', '<leader>:', function() Snacks.picker.command_history() end, { desc = 'Command history' })
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find files' })
map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recent files' })
map('n', '<leader>fg', function() Snacks.picker.grep({ hidden = true, ignored = true }) end, { desc = 'Live grep' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
map('n', '<leader>fh', function() Snacks.picker.help() end, { desc = 'Help tags' })
map('n', '<leader>ft', function() Snacks.picker.treesitter() end, { desc = 'Treesitter' })
map('n', '<leader>fm', function() Snacks.picker.marks() end, { desc = 'Marks' })
map('n', '<leader>fp', function() Snacks.picker.marks() end, { desc = 'Manpage' })
map('n', '<leader>fa', function()
  Snacks.picker.files({ hidden = true, ignored = true })
end, { desc = 'Find hidden files' })
map('n', '<leader>fd', function()
  vim.ui.input({ prompt = "Search path: ", default = "/", completion = "dir" }, function(input)
    if (input == nil or input == "") then
      print("Must specify search path")
      return
    end
    Snacks.picker.grep({
      cwd = input,
    })
  end)
end, { desc = 'Live grep in directory' })

-- git
map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git status' })
map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git branches' })
map('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git diff' })
map('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git log' })
map('n', '<leader>gh', function() Snacks.git.blame_line() end, { desc = 'Git blame line' })
map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git log for file' })
map('n', '<leader>gu', "<cmd>!git pull<CR>", { desc = "Git pull" })
map('n', '<leader>gp', "<cmd>!git push<CR>", { desc = "Git push" })
map('n', '<leader>gc', function()
  vim.ui.input({ prompt = "Commit message: " }, function(input)
    if (input == nil or input == "") then
      print("Must specify commit message")
      return
    end
    vim.cmd("!git commit -m \"" .. input .. "\"")
  end)
end, { desc = "Git commit" })

map('n', '<leader>ga', function()
  vim.ui.input({ prompt = "Search path: ", default = ".", completion = "file" }, function(input)
    if (input == nil or input == "") then
      print("Must specify file to stage")
      return
    end
    vim.cmd("!git add " .. input)
  end)
end, { desc = 'Git add' })

map('n', '<leader>g.', function()
  vim.cmd("!git add %")
end, { desc = 'Git add current file' })

-- lines
map("n", "<leader>ln", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>lr", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>lw", "<cmd>set wrap!<CR>", { desc = "toggle soft-wrap" })
map("n", "<leader>li", function ()
  if Snacks.indent.enabled then
    Snacks.indent.disable()
  else
    Snacks.indent.enable()
  end
end, { desc = "toggle scope indentation" })
-- windows movement
map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })
-- buffers
map('n', '<leader>bl', function() Snacks.picker.buffers() end, { desc = 'Buffers list' })
map('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'Create new buffer' })
-- bufferline
map("n", "H", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev tab" })
map("n", "L", "<cmd>BufferLineCycleNext<CR>", { desc = "Prev tab" })
-- splits
map('n', '<leader>ss', '<cmd>split<cr>', { desc = 'Horizontal split' })
map('n', '<leader>sv', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
-- ZenMode toggle
map("n", "<Leader>z", "<cmd>lua Snacks.zen()<CR>", { desc = "ZenMode toggle" })
--terminal
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Leave terminal with esc" })
map("n", "<leader>t", "<cmd>lua Snacks.terminal.toggle()<CR>", { desc = "Toggle terminal" })
--dap
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Add breakpoint at line" })
map("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "Start or continue the debugger" })
-- Snacks.scratch
map("n", "<leader>nn", function() Snacks.scratch() end, { desc = "Toggle scratch buffer" })
map("n", "<leader>ns", function() Snacks.scratch.select() end, { desc = "Select scratch buffer" })


-- resize split
map("n", "<leader>srv", function()
  vim.ui.input({ prompt = "Resize vsplit: ", default = "+5" }, function(input)
    local sizediff = tonumber(input)
    if (sizediff == nil) then
      print("Must specify number with +/- prefix")
      return
    end
    local sign = "+"
    if (sizediff < 0) then
      sign = ""
    end
    vim.api.nvim_command("vertical resize " .. sign .. sizediff)
  end)
end, { desc = "Resize vertical split" })

map("n", "<leader>srs", function()
  vim.ui.input({ prompt = "Resize split: ", default = "+5" }, function(input)
    local sizediff = tonumber(input)
    if (sizediff == nil) then
      print("Must specify number with +/- prefix")
      return
    end
    local sign = "+"
    if (sizediff < 0) then
      sign = ""
    end
    vim.api.nvim_command("resize " .. sign .. sizediff)
  end)
end, { desc = "Resize split" })

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
    map('n', '<space>rn', vim.lsp.buf.rename, opts "Rename")
    map({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts "Code actions")
    map("n", "<leader>cd", vim.diagnostic.open_float, opts "Diagnostic")
    map("n", "<leader>cf", vim.lsp.buf.format, opts "Format")
    map('n', '<space>cr', vim.lsp.buf.rename, opts "Rename")
    map('n', 'gr', vim.lsp.buf.references, opts "List references to the symbol")
    map('n', '<leader>fr', function() require('telescope.builtin').lsp_references() end,
      { noremap = true, silent = true, desc = "LSP: List references" })
    map('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts "Format")
  end,
})

if TaskTracker then
  map('n', '<leader>ic', function() TaskTracker.createTaskFromTodo() end, { desc = 'Create task from TODO' })
  map('n', '<leader>il', function() TaskTracker.list() end, { desc = 'List tasks' })
  map('n', '<leader>io', function() TaskTracker.openTaskFromLine() end, { desc = 'Open task by ID' })
end
