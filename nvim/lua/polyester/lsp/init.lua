local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("polyester.lsp.handlers").setup()
require("polyester.lsp.config")
require("polyester.lsp.null-ls")
