// Gneiss's docs site, served at gneisstheme.com. The flake
// builds it (nix build .#site), and .github/workflows/site.yml deploys it.
import { readFileSync } from 'node:fs';
import { defineConfig, passthroughImageService } from 'astro/config';
import starlight from '@astrojs/starlight';
import { ExpressiveCodeTheme } from '@astrojs/starlight/expressive-code';

// Code blocks use Gneiss's own VS Code theme, as rendered into dist/.
const gneissCode = ExpressiveCodeTheme.fromJSONString(
	readFileSync(new URL('../dist/vscode/themes/gneiss-color-theme.json', import.meta.url), 'utf-8'),
);

export default defineConfig({
	site: 'https://gneisstheme.com',
	// The site has no raster images to process, so it doesn't need sharp.
	image: { service: passthroughImageService() },
	// The palette page reads ../palette.toml, outside the site's folder.
	vite: { server: { fs: { allow: ['..'] } } },
	integrations: [
		starlight({
			title: 'Gneiss',
			description: "Nord's colors on neutral dark grays.",
			logo: { src: './src/assets/logo.svg' },
			favicon: '/favicon.svg',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/gneiss-theme/gneiss' },
			],
			editLink: { baseUrl: 'https://github.com/gneiss-theme/gneiss/edit/main/site/' },
			customCss: ['./src/styles/gneiss.css'],
			expressiveCode: { themes: [gneissCode] },
			components: {
				Banner: './src/components/Banner.astro',
				Head: './src/components/Head.astro',
				ThemeProvider: './src/components/ThemeProvider.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
			},
			sidebar: [
				{ label: 'Palette', link: '/palette/' },
				{ label: 'Design', link: '/design/' },
				{
					label: 'Apps',
					items: ['apps/neovim', 'apps/vscode', 'apps/alacritty', 'apps/vicinae', 'apps/wayle', 'apps/obsidian', 'apps/nix'],
				},
				{ label: 'Changelog', link: 'https://github.com/gneiss-theme/gneiss/blob/main/CHANGELOG.md' },
			],
		}),
	],
});
