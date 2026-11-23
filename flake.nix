{
  description = "Gneiss: Nord's colors on neutral dark grays";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      # nixpkgs 26.11 dropped x86_64-darwin.
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      palette = import ./nix/palette.nix { inherit lib; };
      portsFor = pkgs: import ./nix/ports.nix { inherit pkgs palette; };
      siteFor = pkgs: import ./nix/site.nix { inherit pkgs palette; };
    in
    {
      # palette.toml, parsed: meta (name, version), base (the base colors)
      # and colors (each role's hex).
      lib.palette = { inherit (palette) meta base colors; };

      packages = forAllSystems (pkgs:
        let ports = portsFor pkgs;
        in ports // { default = ports.dist; site = siteFor pkgs; });

      # nix run .#render: write colors/ and dist/ from the templates.
      apps = forAllSystems (pkgs: {
        render = {
          type = "app";
          meta.description = "Render colors/ and dist/ from palette.toml and templates/";
          program = lib.getExe (pkgs.writeShellApplication {
            name = "gneiss-render";
            runtimeInputs = [ pkgs.git pkgs.coreutils ];
            text = ''
              cd "$(git rev-parse --show-toplevel)"
              if [ ! -f palette.toml ]; then
                echo "gneiss-render: run this inside the gneiss repo" >&2
                exit 1
              fi
              rm -rf colors dist
              cp -r --no-preserve=mode,ownership ${(portsFor pkgs).dist}/. .
              echo "Rendered colors/ and dist/."
            '';
          });
        };

        # nix run .#sync-obsidian -- <dir>: copy the Obsidian theme into a
        # checkout of gneiss-theme/obsidian, the repo Obsidian installs from.
        sync-obsidian = {
          type = "app";
          meta.description = "Copy the Obsidian theme into a checkout of gneiss-theme/obsidian";
          program = lib.getExe (pkgs.writeShellApplication {
            name = "gneiss-sync-obsidian";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              if [ $# -ne 1 ] || [ ! -d "$1/.git" ]; then
                echo "usage: nix run .#sync-obsidian -- <checkout of gneiss-theme/obsidian>" >&2
                exit 1
              fi
              install -m644 ${(portsFor pkgs).obsidian}/theme.css ${(portsFor pkgs).obsidian}/manifest.json "$1/"
              echo "Copied Gneiss ${palette.meta.version}'s theme.css and manifest.json to $1."
            '';
          });
        };
      });

      checks = forAllSystems (pkgs: import ./nix/checks.nix {
        inherit pkgs self palette;
        ports = portsFor pkgs;
        site = siteFor pkgs;
      });
    };
}
