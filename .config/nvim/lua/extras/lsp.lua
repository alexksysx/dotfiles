-- local M = {}
local lspconfig = require "lspconfig"
--
-- M.on_attach = function(_, bufnr)
--   local function opts(desc)
--     return { buffer = bufnr, desc = "LSP " .. desc }
--   end
--
--   map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
--   map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
--   map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
--   map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
--   map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
--   map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
--
--   map("n", "<leader>wl", function()
--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--   end, opts "List workspace folders")
--
--   map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
--   map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
--
--   map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
--   map("n", "gr", vim.lsp.buf.references, opts "Show references")
-- end
--
-- -- disable semanticTokens
-- M.on_init = function(client, _)
--   if client.supports_method "textDocument/semanticTokens" then
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- end
--
-- M.capabilities = vim.lsp.protocol.make_client_capabilities()
--
-- M.capabilities.textDocument.completion.completionItem = {
--   documentationFormat = { "markdown", "plaintext" },
--   snippetSupport = true,
--   preselectSupport = true,
--   insertReplaceSupport = true,
--   labelDetailsSupport = true,
--   deprecatedSupport = true,
--   commitCharactersSupport = true,
--   tagSupport = { valueSet = { 1 } },
--   resolveSupport = {
--     properties = {
--       "documentation",
--       "detail",
--       "additionalTextEdits",
--     },
--   },
-- }


lspconfig.lua_ls.setup {}
lspconfig.clangd.setup {}
lspconfig.cmake.setup{}
lspconfig.pylsp.setup{}
lspconfig.ts_ls.setup{}
lspconfig.svelte.setup{}
