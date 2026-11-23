# nix flake check: the rendered files are current, the palette keeps the
# contrast it's designed around, and the ports load.
{ pkgs, self, palette, ports }:
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
}
# And every package builds.
// lib.mapAttrs' (name: lib.nameValuePair "package-${name}") ports
