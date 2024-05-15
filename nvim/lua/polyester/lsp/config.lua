local servers = {
	"nil_ls",
	"lua_ls",
	"clangd",
	"haxe_language_server",
	"bashls",
	"tsserver",
	"texlab",
	"tailwindcss",
	"asm_lsp",
}

local api = vim.api
local k = vim.keymap.set

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

-- https://github.com/itslychee/config/blob/nixos/nvim/lua/fruit/lsp.lua#L22C1-L45C3LSP
api.nvim_create_autocmd("LspAttach", {
	group = api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		local opts = { buffer = ev.buf }
		k("n", "<space>D", vim.lsp.buf.type_definition, opts)
		k("n", "gD", vim.lsp.buf.declaration, opts)
		k("n", "gd", vim.lsp.buf.definition, opts)
		k("n", "gr", vim.lsp.buf.references, opts)
		k("n", "K", vim.lsp.buf.hover, opts)
		k("n", "gi", vim.lsp.buf.implementation, opts)
		k("n", "<C-k>", vim.lsp.buf.signature_help, opts)

		-- Workspace
		-- k("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		-- k("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		-- k("n", "<space>wl", function()
		-- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, opts)
		-- k("n", "<space>rn", vim.lsp.buf.rename, opts)
		-- k({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
	end,
})
