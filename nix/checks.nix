# nix flake check: the rendered files are current, the palette keeps the
# contrast it's designed around, and the ports load.
{ pkgs, self, palette, ports, site }:
let
  inherit (pkgs) lib;
  baseJson = pkgs.writeText "gneiss-base.json" (builtins.toJSON palette.base);
in
{
  # colors/ and dist/ are what the templates render to now.
  rendered = pkgs.runCommandLocal "gneiss-check-rendered" { } ''
    for dir in colors dist; do
      if ! diff -r ${ports.dist}/$dir ${self}/$dir; then
        echo "$dir/ doesn't match the templates. Run 'nix run .#render' and commit the result." >&2
        exit 1
      fi
    done
    touch $out
  '';

  # The contrast ratios palette.toml describes, plus every color's ratio
  # against the background, in the check's output.
  contrast = pkgs.runCommandLocal "gneiss-check-contrast"
    { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 -I ${../checks/contrast.py} ${../palette.toml} | tee $out
  '';

  # Neovim loads the colorscheme with no errors, with the palette's colors.
  neovim = pkgs.runCommandLocal "gneiss-check-neovim"
    { nativeBuildInputs = [ pkgs.neovim ]; } ''
    export HOME=$TMPDIR XDG_CONFIG_HOME=$TMPDIR XDG_DATA_HOME=$TMPDIR XDG_STATE_HOME=$TMPDIR XDG_CACHE_HOME=$TMPDIR
    nvim --clean --headless --cmd "set rtp^=${ports.neovim}" \
      -l ${../checks/neovim.lua} ${baseJson} | tee $out
  '';

  # The Obsidian theme keeps to the rules of Obsidian's theme directory: a
  # manifest with the required fields, a name without "Theme", nothing
  # fetched from the network and no !important.
  obsidian = pkgs.runCommandLocal "gneiss-check-obsidian"
    { nativeBuildInputs = [ pkgs.jq pkgs.gnugrep ]; } ''
    theme=${ports.obsidian}
    jq -e '(.name | type == "string") and (.author | type == "string")
      and (.minAppVersion | type == "string") and (.name | test("theme"; "i") | not)' \
      "$theme/manifest.json" > /dev/null
    jq -e '.version == "${palette.meta.version}"' "$theme/manifest.json" > /dev/null
    if grep -nE 'url\(|@import|!important|\{\{' "$theme/theme.css"; then
      echo "theme.css fetches something, uses !important, or has something left in double braces." >&2
      exit 1
    fi
    touch $out
  '';

  # The VS Code extension's manifest and theme parse, with nothing left
  # unfilled.
  vscode = pkgs.runCommandLocal "gneiss-check-vscode"
    { nativeBuildInputs = [ pkgs.jq ]; } ''
    ext=$(echo ${ports.vscode}/share/vscode/extensions/*)
    jq -e '.version == "${palette.meta.version}"' "$ext/package.json" > /dev/null
    jq -e '(.colors | length > 0) and (.tokenColors | length > 0)' \
      "$ext/themes/gneiss-color-theme.json" > /dev/null
    if grep -rl --include='*.json' '{{' "$ext"; then
      echo "These files have something left in double braces." >&2
      exit 1
    fi
    touch $out
  '';

  # The VSIX the stores get is Gneiss's version from gneiss-theme, marked as
  # a preview.
  vsix = pkgs.runCommandLocal "gneiss-check-vsix"
    { nativeBuildInputs = [ pkgs.unzip pkgs.gnugrep ]; } ''
    manifest=$(unzip -p ${ports.vsix} extension.vsixmanifest)
    grep -q 'Id="gneiss" Version="${palette.meta.version}" Publisher="gneiss-theme"' <<<"$manifest"
    grep -q '<GalleryFlags>Public Preview</GalleryFlags>' <<<"$manifest"
    touch $out
  '';
}
# And every package builds, the site included.
// lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (ports // { inherit site; })
