# The docs site, built with Astro from site/. It reads palette.toml and the
# rendered VS Code theme (for its code blocks) from the rest of the repo.
# Each npm package in site/package-lock.json is fetched by its own hash, so
# changing the site's dependencies needs no hash here.
{ pkgs, palette }:
let
  inherit (pkgs) lib;
  fs = lib.fileset;

  src = fs.toSource {
    root = ./..;
    fileset = fs.unions [
      ../palette.toml
      ../dist/vscode/themes/gneiss-color-theme.json
      (fs.difference ../site (fs.unions (map fs.maybeMissing [
        ../site/node_modules
        ../site/dist
        ../site/.astro
      ])))
    ];
  };
in
pkgs.buildNpmPackage {
  pname = "gneiss-site";
  inherit (palette.meta) version;
  inherit src;
  sourceRoot = "${src.name}/site";

  npmDeps = pkgs.importNpmLock {
    package = lib.importJSON ../site/package.json;
    packageLock = lib.importJSON ../site/package-lock.json;
  };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  # Astro and Starlight check for updates and send telemetry unless told not to.
  env.ASTRO_TELEMETRY_DISABLED = "1";

  installPhase = ''
    runHook preInstall
    cp -r dist "$out"
    runHook postInstall
  '';
}
