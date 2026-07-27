import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const toolsDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectDirectory = path.resolve(toolsDirectory, '..');
const themeFiles = {
  Light: path.join(
    projectDirectory,
    'entry/src/main/resources/base/element/color.json'
  ),
  Dark: path.join(
    projectDirectory,
    'entry/src/main/resources/dark/element/color.json'
  )
};

const contrastCases = [
  {
    label: 'Primary text / page',
    foreground: 'ink_primary',
    background: 'background_page',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Primary text / raised card',
    foreground: 'ink_primary',
    background: 'surface_elevated',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Muted text / primary surface',
    foreground: 'ink_muted',
    background: 'surface_primary',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Muted disabled text / disabled surface',
    foreground: 'ink_muted',
    background: 'surface_disabled',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Tertiary small text / page',
    foreground: 'ink_tertiary',
    background: 'background_page',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Tertiary small text / primary surface',
    foreground: 'ink_tertiary',
    background: 'surface_primary',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Tertiary placeholder / pure surface',
    foreground: 'ink_tertiary',
    background: 'surface_pure',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Brand text / primary surface',
    foreground: 'accent_text',
    background: 'surface_primary',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Brand text / soft brand surface',
    foreground: 'accent_text',
    background: 'brand_soft',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Brand text / soft accent surface',
    foreground: 'accent_text',
    background: 'surface_accent_soft',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Confirm text / primary surface',
    foreground: 'confirm_text',
    background: 'surface_primary',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Confirm text / soft brand surface',
    foreground: 'confirm_text',
    background: 'brand_soft',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Confirm text / soft confirm surface',
    foreground: 'confirm_text',
    background: 'surface_confirm_soft',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Button text / brand fill',
    foreground: 'on_emphasis',
    background: 'accent',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Button text / brand gradient start',
    foreground: 'on_emphasis',
    background: 'accent_gradient_start',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Button text / brand gradient end',
    foreground: 'on_emphasis',
    background: 'accent_gradient_end',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Button text / confirm fill',
    foreground: 'on_emphasis',
    background: 'confirm',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Secondary passport text / confirm fill',
    foreground: 'on_emphasis_secondary',
    background: 'confirm',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Error text / primary surface',
    foreground: 'danger',
    background: 'surface_primary',
    lightMinimum: 4.5,
    darkMinimum: 5
  },
  {
    label: 'Exit text / recording surface',
    foreground: 'danger',
    background: 'surface_recording',
    lightMinimum: 4.5,
    darkMinimum: 4.5
  },
  {
    label: 'Focus indicator / primary surface',
    foreground: 'focus',
    background: 'surface_primary',
    lightMinimum: 3,
    darkMinimum: 3
  },
  {
    label: 'Active brand fill / primary surface',
    foreground: 'accent',
    background: 'surface_primary',
    lightMinimum: 2.2,
    darkMinimum: 2.2
  },
  {
    label: 'Active confirm fill / primary surface',
    foreground: 'confirm',
    background: 'surface_primary',
    lightMinimum: 2.2,
    darkMinimum: 2.2
  }
];

const avatarTokens = [
  'avatar_cantonese',
  'avatar_shanghai',
  'avatar_beijing',
  'avatar_default'
];

for (const token of avatarTokens) {
  contrastCases.push({
    label: `Avatar text / ${token}`,
    foreground: 'on_emphasis',
    background: token,
    lightMinimum: 4.5,
    darkMinimum: 5
  });
}

function loadTheme(filePath) {
  const parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const entries = parsed.color;
  if (!Array.isArray(entries)) {
    throw new Error(`Missing color array in ${filePath}`);
  }

  const colors = new Map();
  for (const entry of entries) {
    if (colors.has(entry.name)) {
      throw new Error(`Duplicate color token "${entry.name}" in ${filePath}`);
    }
    colors.set(entry.name, entry.value);
  }
  return colors;
}

function opaqueRgb(colorValue, tokenName) {
  if (!/^#[0-9A-Fa-f]{6}$/.test(colorValue)) {
    throw new Error(
      `Contrast token "${tokenName}" must use opaque #RRGGBB, got ${colorValue}`
    );
  }
  return [1, 3, 5].map((start) =>
    Number.parseInt(colorValue.slice(start, start + 2), 16) / 255
  );
}

function relativeLuminance(colorValue, tokenName) {
  const [red, green, blue] = opaqueRgb(colorValue, tokenName).map((channel) =>
    channel <= 0.03928
      ? channel / 12.92
      : Math.pow((channel + 0.055) / 1.055, 2.4)
  );
  return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

function contrastRatio(foregroundValue, backgroundValue, foreground, background) {
  const foregroundLuminance = relativeLuminance(foregroundValue, foreground);
  const backgroundLuminance = relativeLuminance(backgroundValue, background);
  const lighter = Math.max(foregroundLuminance, backgroundLuminance);
  const darker = Math.min(foregroundLuminance, backgroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

const themes = Object.fromEntries(
  Object.entries(themeFiles).map(([name, filePath]) => [name, loadTheme(filePath)])
);
const lightTokens = [...themes.Light.keys()].sort();
const darkTokens = [...themes.Dark.keys()].sort();
if (JSON.stringify(lightTokens) !== JSON.stringify(darkTokens)) {
  throw new Error('Light and Dark color token sets do not match');
}

let failed = false;
console.log(
  '| Theme | Pair | Foreground | Background | Ratio | Minimum | Result |'
);
console.log('| --- | --- | --- | --- | ---: | ---: | --- |');

for (const [themeName, colors] of Object.entries(themes)) {
  for (const contrastCase of contrastCases) {
    const foregroundValue = colors.get(contrastCase.foreground);
    const backgroundValue = colors.get(contrastCase.background);
    if (foregroundValue === undefined || backgroundValue === undefined) {
      throw new Error(
        `Missing ${themeName} token for ${contrastCase.label}`
      );
    }

    const minimum = themeName === 'Light'
      ? contrastCase.lightMinimum
      : contrastCase.darkMinimum;
    const ratio = contrastRatio(
      foregroundValue,
      backgroundValue,
      contrastCase.foreground,
      contrastCase.background
    );
    const passed = ratio + Number.EPSILON >= minimum;
    failed = failed || !passed;
    console.log(
      `| ${themeName} | ${contrastCase.label} | ` +
      `${contrastCase.foreground} ${foregroundValue} | ` +
      `${contrastCase.background} ${backgroundValue} | ` +
      `${ratio.toFixed(2)}:1 | ${minimum.toFixed(1)}:1 | ` +
      `${passed ? 'PASS' : 'FAIL'} |`
    );
  }
}

console.log(`\nValidated ${lightTokens.length} aligned Light/Dark color tokens.`);
if (failed) {
  process.exitCode = 1;
}
