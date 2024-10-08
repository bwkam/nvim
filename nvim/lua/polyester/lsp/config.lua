local servers = {
  "nil_ls",
  "lua_ls",
  "clangd",
  "haxe_language_server",
  "html",
  "bashls",
  "tsserver",
  "texlab",
  "tailwindcss",
  "asm_lsp",
  "tinymist",
  "pyright",
  "zls",
  "gopls",
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("polyester.lsp.handlers").on_attach,
    capabilities = require("polyester.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]

  local require_ok, conf_opts = pcall(require, "polyester.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end

  lspconfig[server].setup(opts)
end
