{ lib, self }:
lib.concatLines (
  (map (x: "luafile ${self}/lua/${x}.lua") (
    [
      "options"
      "keymaps"
      "flash"
      "colorscheme"
      # "neorg"
      "cmp"
      "telescope"
      "nvim-web-devicons"
      "treesitter"
      "autopairs"
      "comment"
      "gitsigns"
      "nvim-tree"
      "bufferline"
      "dashboard"
      # "toggleterm"
      "which-key"
      # "nvim-ufo"
      "lualine"
      "colorizer"
    ]

    ++ lib.pipe "${self}/lua/lsp" [
      builtins.unsafeDiscardStringContext
      lib.filesystem.listFilesRecursive
      (builtins.filter (lib.hasSuffix ".lua"))
      (map (lib.removeSuffix ".lua"))
      (map (lib.removePrefix "${self}/lua/"))
    ]

    # ++ (map (x: builtins.replaceStrings [ ".lua" ] [ "" ] x) (
    #   map (x: "lsp" + (lib.last (lib.splitString "lsp" (toString x)))) (
    #     lib.filesystem.listFilesRecursive ./lsp
    #   )
    # ))
  ))
)
