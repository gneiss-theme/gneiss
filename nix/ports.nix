# Gneiss's ports, rendered from templates/ with the palette.
{ pkgs, palette }:
let
  inherit (pkgs) lib;
  inherit (palette.meta) version;

  render = name: template:
    pkgs.writeText name (palette.render name (builtins.readFile template));

  manifest = lib.importJSON ../templates/vscode/package.json;

  colorscheme = render "gneiss.lua" ../templates/neovim.lua;

  # The VS Code extension's folder, as vsce packages it and VS Code installs it.
  vscodeFolder = pkgs.runCommandLocal "gneiss-vscode" { } ''
    mkdir -p "$out/themes"
    cp ${render "package.json" ../templates/vscode/package.json} "$out/package.json"
    cp ${render "gneiss-color-theme.json" ../templates/vscode/themes/gneiss-color-theme.json} \
      "$out/themes/gneiss-color-theme.json"
    cp ${../templates/vscode/README.md} "$out/README.md"
    cp ${../templates/vscode/icon.png} "$out/icon.png"
    cp ${../CHANGELOG.md} "$out/CHANGELOG.md"
    cp ${../LICENSE} "$out/LICENSE"
    cp ${../NOTICE} "$out/NOTICE"
  '';
in
rec {
  # An Alacritty config file with the colors, to import.
  alacritty = render "gneiss-alacritty.toml" ../templates/alacritty.toml;

  # A Vicinae theme, for Vicinae's themes folder.
  vicinae = render "gneiss.toml" ../templates/vicinae.toml;

  # A Wayle theme, for Wayle's themes folder.
  wayle = render "gneiss-wayle.toml" ../templates/wayle.toml;

  # An Obsidian theme: the folder Obsidian installs to its themes folder,
  # with theme.css and manifest.json.
  obsidian = pkgs.runCommandLocal "gneiss-obsidian" { } ''
    install -Dm644 ${render "theme.css" ../templates/obsidian/theme.css} "$out/theme.css"
    install -Dm644 ${render "manifest.json" ../templates/obsidian/manifest.json} "$out/manifest.json"
  '';

  # A Neovim plugin with the "gneiss" colorscheme.
  neovim = pkgs.vimUtils.buildVimPlugin {
    pname = "gneiss";
    inherit version;
    src = pkgs.runCommandLocal "gneiss-nvim" { } ''
      install -Dm644 ${colorscheme} "$out/colors/gneiss.lua"
      install -Dm644 ${../LICENSE} "$out/LICENSE"
      install -Dm644 ${../NOTICE} "$out/NOTICE"
    '';
  };

  # A VS Code extension with the "Gneiss" color theme.
  vscode = pkgs.vscode-utils.buildVscodeExtension {
    pname = "gneiss";
    inherit version;
    vscodeExtPublisher = manifest.publisher;
    vscodeExtName = manifest.name;
    vscodeExtUniqueId = "${manifest.publisher}.${manifest.name}";

    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/$installPrefix"
      cp -r ${vscodeFolder}/. "$out/$installPrefix/"
      runHook postInstall
    '';
  };

  # The VS Code extension packaged as a VSIX, as the stores and GitHub
  # releases take it.
  vsix = pkgs.runCommandLocal "gneiss-${version}.vsix" { nativeBuildInputs = [ pkgs.vsce ]; } ''
    cp -r --no-preserve=mode ${vscodeFolder} extension
    cd extension
    HOME=$TMPDIR vsce package --no-dependencies --out "$out"
  '';

  # Every rendered file, laid out as committed in the repo: colors/ for
  # Neovim's plugin managers, dist/ for everything else.
  dist = pkgs.runCommandLocal "gneiss-dist" { } ''
    install -Dm644 ${colorscheme} "$out/colors/gneiss.lua"
    install -Dm644 ${alacritty} "$out/dist/alacritty/gneiss.toml"
    install -Dm644 ${vicinae} "$out/dist/vicinae/gneiss.toml"
    install -Dm644 ${wayle} "$out/dist/wayle/gneiss.toml"
    mkdir -p "$out/dist/obsidian"
    cp ${obsidian}/* "$out/dist/obsidian/"
    mkdir -p "$out/dist/vscode"
    cp -r ${vscodeFolder}/. "$out/dist/vscode/"
  '';
}
