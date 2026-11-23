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
| VS Code | Coming to the VS Code Marketplace and Open VSX. Until then, through Nix (below). |
| Alacritty | Download [`dist/alacritty/gneiss.toml`](dist/alacritty/gneiss.toml) and import it (below). |
| Vicinae | Copy [`dist/vicinae/gneiss.toml`](dist/vicinae/gneiss.toml) to `~/.config/vicinae/themes/`, then choose Gneiss in Vicinae's settings. |
| Obsidian | Planned. |

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

```sh
nix run .#render   # render colors/ and dist/ from the templates
nix flake check    # check that they're current, plus contrast and loading
```

CI runs `nix flake check` on x86_64 and aarch64 Linux and Apple silicon
macOS, for every push to `main` and every pull request.

The flake reads only files git tracks, so `git add` a new template before
rendering.

## Credits and license

Gneiss is MIT licensed; see [LICENSE](LICENSE). Its colors began as
[Nord](https://www.nordtheme.com)'s. Its VS Code theme began as a fork of
[Nord's VS Code theme](https://github.com/nordtheme/visual-studio-code), and
its Neovim colorscheme as a fork of
[nord.nvim](https://github.com/gbprod/nord.nvim). [NOTICE](NOTICE) has their
licenses. Gneiss isn't affiliated with Nord.
