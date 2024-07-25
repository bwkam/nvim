local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
  debug = false,
  sources = {
    formatting.stylua,
    formatting.alejandra,
    formatting.typstfmt,
    formatting.black,
    formatting.prettier,
    code_actions.statix,
    diagnostics.deadnix,
  },
})
