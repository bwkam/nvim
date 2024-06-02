{
  description = "my neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
    neorg-overlay,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = f: lib.genAttrs systems f;

    languages = (
      p:
        map (x: p.${x}) [
          "haskell"
          "nix"
          "lua"
          "norg"
          "typescript"
          "javascript"
          "latex"
          "markdown"
          "asm"
          "typst"
          "bash"
        ]
    );
  in {
    packages = perSystem (
      system: let
        pkgs = import nixpkgs {
          overlays = [neorg-overlay.overlays.default neovim-nightly-overlay.overlay];
          inherit system;
        };
      in {
        neovim = with pkgs;
          (
            wrapNeovimUnstable neovim-unwrapped
            (
              neovimUtils.makeNeovimConfig {
                plugins =
                  [
                    (vimUtils.buildVimPlugin {
                      name = "polyester";
                      dependencies =
                        [(vimPlugins.nvim-treesitter.withPlugins languages)]
                        ++ lib.mapAttrsToList (name: src: (vimUtils.buildVimPlugin {inherit name src;})) (import ./npins);
                      src = "${self}/nvim";
                    })
                  ]
                  ++ (with vimPlugins; [neorg neorg-telescope]);

                wrapRc = false;
              }
            )
          )
          .overrideAttrs
          (old: {
            generatedWrapperArgs =
              old.generatedWrapperArgs
              or []
              ++ [
                "--prefix"
                "PATH"
                ":"
                (lib.makeBinPath [
                  # nix
                  deadnix
                  statix
                  alejandra
                  nil

                  # lua
                  lua-language-server
                  stylua

                  ripgrep
                  nodejs
                  haxe

                  # haskell
                  haskell-language-server
                  ghc
                  cabal-install

                  # typst
                  tinymist
                  typstfmt
                  typst-preview
                ])
              ];
          });
      }
    );

    devShells = perSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {buildInputs = with pkgs; [npins];};
      }
    );
  };
}
