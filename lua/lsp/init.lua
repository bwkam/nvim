local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

-- require "user.lsp.null-ls"
require("lsp.handlers").setup()
require("lsp.config")
require("lsp.null-ls")


