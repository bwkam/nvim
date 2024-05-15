{
  description = "my neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
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
          "bash"
        ]
    );
  in {
    packages = perSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system}.extend (neovim-nightly-overlay.overlay);
      in {
        neovim = with pkgs;
          (
            wrapNeovimUnstable neovim-unwrapped
            (
              neovimUtils.makeNeovimConfig {
                plugins = [
                  (vimUtils.buildVimPlugin {
                    name = "polyester";
                    dependencies =
                      [(vimPlugins.nvim-treesitter.withPlugins languages)]
                      ++ lib.mapAttrsToList (name: src: (vimUtils.buildVimPlugin {inherit name src;})) (import ./npins);
                    src = "${self}/nvim";
                  })
                ];

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
                  deadnix
                  statix
                  lua-language-server
                  ripgrep
                  nil
                  stylua
                  alejandra
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
