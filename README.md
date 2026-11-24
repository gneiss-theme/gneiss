# Gneiss

> [!NOTE]
> **Gneiss is pre-1.0 and subject to change.** It's being built out now, and
> its colors, names and ports may change before 1.0. Every color change is
> listed in the [changelog](CHANGELOG.md).

Gneiss (pronounced "nice", after the gray, banded bedrock of the Nordic
countries) is Nord's colors on neutral dark grays.

It keeps Nord's syntax and status colors, which are distinct enough to tell
apart at a glance without anything shouting. It swaps Nord's blue-gray
backgrounds for neutral grays with the same contrast steps between them, so
the result reads like Nord in a darker, quieter room. Gneiss started as a
copy of Nord's values and is its own theme from there: a change to Nord
doesn't change Gneiss.

The docs site, [gneisstheme.com](https://gneisstheme.com/),
has the palette with its contrast ratios, how Gneiss was designed, and how
to install each port.

## Palette

The base colors are numbered like Nord's, so any port can be compared with
Nord's.

| Color | Hex | Use |
|---|---|---|
| `gneiss0` | `#1C1C1C` | editor and window background |
| `gneiss1` | `#2D2D2D` | panels, status bars, the current line |
| `gneiss2` | `#383838` | selection, raised controls |
| `gneiss3` | `#424242` | borders, indent guides |
| `gneiss-comment` | `#6E6E6E` | comments |
| `gneiss4` | `#D8DEE9` | body text |
| `gneiss5` | `#E5E9F0` | |
| `gneiss6` | `#ECEFF4` | punctuation, emphasis |
| `gneiss7` | `#8FBCBB` | attribute names, types |
| `gneiss8` | `#88C0D0` | functions; the main accent |
| `gneiss9` | `#81A1C1` | keywords, operators |
| `gneiss10` | `#5E81AC` | deep blue, for hints |
| `gneiss11` | `#BF616A` | errors, deletions |
| `gneiss12` | `#D08770` | used sparingly |
| `gneiss13` | `#EBCB8B` | warnings |
| `gneiss14` | `#A3BE8C` | strings, additions |
| `gneiss15` | `#B48EAD` | numbers |

The four background grays keep Nord's steps: 1.24, 1.45 and 1.69 to 1
against the background, as `nord1` to `nord3` are against `nord0`. The
comment gray is as light as Nord's comment color. The text and accent colors
are Nord's values. [`palette.toml`](palette.toml) also names roles (`bg`,
`fg-muted`, `accent` and so on) for apps themed from raw colors.

## Ports

| App | Install |
|---|---|
| Neovim | Install this repo as a plugin (see below), then `:colorscheme gneiss`. |
| VS Code | Install `gneiss-theme.gneiss-vscode` from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=gneiss-theme.gneiss-vscode) or [Open VSX](https://open-vsx.org/extension/gneiss-theme/gneiss-vscode). |
| Alacritty | Download [`dist/alacritty/gneiss.toml`](dist/alacritty/gneiss.toml) and import it (below). |
| Vicinae | Copy [`dist/vicinae/gneiss.toml`](dist/vicinae/gneiss.toml) to `~/.config/vicinae/themes/`, then choose Gneiss in Vicinae's settings. |
| Obsidian | In Obsidian's theme directory: Settings → Appearance → Themes → Manage, then search for Gneiss. Or copy [`dist/obsidian/`](dist/obsidian) to your vault's `.obsidian/themes/Gneiss/`. |

**Neovim**, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "gneiss-theme/gneiss",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("gneiss")
  end,
}
```

**Alacritty**, after saving the file to `~/.config/alacritty/gneiss.toml`:

```toml
[general]
import = ["~/.config/alacritty/gneiss.toml"]
```

## Nix

The flake has every port as a package, and the palette as data:

```nix
# flake.nix
inputs.gneiss = {
  url = "github:gneiss-theme/gneiss";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
# A Home Manager module, with inputs passed in
{ inputs, pkgs, ... }:
let
  gneiss = inputs.gneiss.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.neovim.plugins = [ gneiss.neovim ];
  programs.vscode.profiles.default.extensions = [ gneiss.vscode ];
  programs.alacritty.settings.general.import = [ "${gneiss.alacritty}" ];
  xdg.configFile."vicinae/themes/gneiss.toml".source = gneiss.vicinae;
}
```

`inputs.gneiss.lib.palette` has the colors as data: `meta`, `base` (the
table above) and `colors` (each role's hex).

## How it's built

[`palette.toml`](palette.toml) holds every color. Each port is a template in
[`templates/`](templates) that names base colors in double braces, such as
`gneiss8`. The flake fills them in. The results are committed, for people
installing without Nix: [`colors/`](colors) holds the Neovim colorscheme,
at the root so plugin managers can install this repo, and [`dist/`](dist)
holds everything else.

[`site/`](site) is the docs site, built with Astro Starlight from the same
`palette.toml` and deployed to GitHub Pages from `main`.
[gneiss-theme/obsidian](https://github.com/gneiss-theme/obsidian) is the
repo Obsidian installs the theme from, and
`nix run .#sync-obsidian -- <checkout>` copies the rendered theme into a
checkout of it.

```sh
nix run .#render   # render colors/ and dist/ from the templates
nix flake check    # check that they're current, plus contrast and loading
nix build .#site   # build the docs site into ./result
```

CI runs `nix flake check` on x86_64 and aarch64 Linux, for every push to
`main` and every pull request.

The flake reads only files git tracks, so `git add` a new template before
rendering.

## Releasing

1. Set the new `version` in `palette.toml`, give it a dated section in
   `CHANGELOG.md`, such as `## 0.2.0 (2026-12-01)`, run `nix run .#render`,
   and commit.
2. Tag the commit `v0.2.0` and push the tag. The
   [release workflow](.github/workflows/release.yml) runs the checks,
   publishes the VS Code extension to the Visual Studio Marketplace and Open
   VSX, and creates a GitHub release with every port's files.
3. For Obsidian, run `nix run .#sync-obsidian -- <checkout>` on a checkout
   of [gneiss-theme/obsidian](https://github.com/gneiss-theme/obsidian),
   commit, and push a tag of the bare version, such as `0.2.0`. Its own
   workflow releases the theme, which Obsidian then offers as an update.

## Credits and license

Gneiss is MIT licensed; see [LICENSE](LICENSE). Its colors began as
[Nord](https://www.nordtheme.com)'s. Its VS Code theme began as a fork of
[Nord's VS Code theme](https://github.com/nordtheme/visual-studio-code), and
its Neovim colorscheme as a fork of
[nord.nvim](https://github.com/gbprod/nord.nvim). [NOTICE](NOTICE) has their
licenses. Gneiss isn't affiliated with Nord.
