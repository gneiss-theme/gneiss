// Gneiss's palette, read from palette.toml when the site builds, and the
// WCAG 2 contrast ratios worked out from it, as checks/contrast.py does.
import source from '../../../palette.toml?raw';
import { parse } from 'smol-toml';

type Palette = {
	meta: { name: string; version: string };
	base: Record<string, string>;
	colors: Record<string, string>;
};
const palette = parse(source) as unknown as Palette;

export const { meta, base } = palette;

// Each role, the base color it names (or null for a hex of Gneiss's own),
// and its hex.
export const roles = Object.entries(palette.colors).map(([role, value]) => ({
	role,
	from: value in base ? value : null,
	hex: base[value] ?? value,
}));

export const role = (name: string) => roles.find((r) => r.role === name)!.hex;

// The comment after each color in palette.toml, such as "body text".
const comments = new Map(
	[...source.matchAll(/^([a-z0-9-]+)\s*=\s*"[^"]*"\s*#\s*(.+)$/gm)].map((m) => [m[1], m[2].trim()]),
);
export const describe = (name: string) => comments.get(name) ?? '';

// Nord's colors that Gneiss's grays were measured against, as in
// checks/contrast.py. Gneiss doesn't follow them.
export const nord = {
	nord0: '#2E3440',
	nord1: '#3B4252',
	nord2: '#434C5E',
	nord3: '#4C566A',
	'nord-comment': '#616E88',
};

export function luminance(hex: string) {
	const [r, g, b] = [1, 3, 5].map((i) => {
		const c = parseInt(hex.slice(i, i + 2), 16) / 255;
		return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
	});
	return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export function ratio(a: string, b: string) {
	const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
	return (light + 0.05) / (dark + 0.05);
}

export const formatRatio = (r: number) => `${r.toFixed(2)}:1`;

// The text color to label a swatch with: the darkest or lightest gray,
// whichever reads better on it.
export const labelOn = (hex: string) =>
	ratio(hex, base.gneiss0) > ratio(hex, base.gneiss6) ? base.gneiss0 : base.gneiss6;
