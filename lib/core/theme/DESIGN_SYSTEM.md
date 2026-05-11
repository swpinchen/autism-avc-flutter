# AVC Calendar — Design System Reference

Source: [Figma AVC-Calendar-Designs](https://www.figma.com/design/diqOxShWAoaPCGEPOzdg06/AVC-Calendar-Designs)

## Color Palette

### Primary Blue
| Token           | Hex       | Usage                        |
|-----------------|-----------|------------------------------|
| lighter-30      | `#F4F3FF` | Backgrounds, segmented btn   |
| lighter-20      | `#E1DFFF` | Primary container, today bg  |
| lighter-10      | `#9D99D4` | Dark-mode primary            |
| base            | `#7571AB` | Primary actions, accent bars |
| darker-10       | `#4B477C` | On-primary-container, text   |

### Blossom Pink
| Token           | Hex       | Usage                        |
|-----------------|-----------|------------------------------|
| lighter-30      | `#FFE7F5` | Subtle pink backgrounds      |
| lighter-20      | `#FFD7EF` | Secondary container          |
| lighter-10      | `#FFB0DF` | Dark-mode secondary          |
| base            | `#F475C1` | Calendar markers, secondary  |
| darker-10       | `#DE369B` | On-secondary-container       |

### Brilliant Teal
| Token           | Hex       | Usage                        |
|-----------------|-----------|------------------------------|
| lighter-30      | `#E0F7F7` | —                            |
| lighter-20      | `#B2EBEB` | Tertiary container           |
| lighter-10      | `#7ABFBF` | Dark-mode tertiary           |
| base            | `#4FA3A3` | Tertiary actions             |
| darker-10       | `#2E7D7D` | On-tertiary-container        |

### Neutral Gray
| Token           | Hex       | Usage                            |
|-----------------|-----------|----------------------------------|
| lighter-30      | `#F8F8F8` | Page background (`surface`)      |
| lighter-20      | `#EFEFEF` | Emoji pill bg, surfaceContainer  |
| lighter-10      | `#DFDFDF` | Borders, dividers                |
| base            | `#CACACA` | Placeholder text                 |
| darker-10       | `#9D9D9D` | Inactive icons, outlines         |
| darker-20       | `#6F6F6F` | Secondary text                   |
| darker-30       | `#303030` | Primary text (`onSurface`)       |

### Contextual Colors
| Role     | lighter-20  | lighter-10  | base        | darker-10   |
|----------|-------------|-------------|-------------|-------------|
| Danger   | `#FFC7C7`   | `#E88B8B`   | `#D25A5A`   | `#A82020`   |
| Success  | `#D5F0D5`   | `#8BC8A4`   | `#5BA87A`   | `#2E7D56`   |
| Warning  | `#FFF3CC`   | `#FFE494`   | `#FFD54F`   | `#F5C623`   |

### Special
| Token           | Hex       | Usage                          |
|-----------------|-----------|--------------------------------|
| highlight pink  | `#FF8EBE` | Child card tap glow animation  |

## Typography

### English
| Style     | Family  | Weight | Size | Line Height |
|-----------|---------|--------|------|-------------|
| H1        | Poppins | Bold   | 32   | 40          |
| H2        | Karla   | Regular| 24   | 32          |
| Body L    | Karla   | Regular| 20   | 28          |
| Body M    | Karla   | Regular| 16   | 24          |
| Body S    | Karla   | Regular| 14   | 20          |
| Label L   | Poppins | Bold   | 20   | 24          |
| Label S   | Poppins | Bold   | 16   | 20          |

### Japanese
| Style     | Family       | Weight | Size | Line Height |
|-----------|--------------|--------|------|-------------|
| H1        | Noto Sans JP | Bold   | 32   | 40          |
| H2        | Noto Sans JP | Regular| 24   | 32          |
| Body L    | Noto Sans JP | Regular| 20   | 28          |
| Body M    | Noto Sans JP | Regular| 16   | 28          |
| Body S    | Noto Sans JP | Regular| 14   | 24          |
| Label L   | Noto Sans JP | Bold   | 20   | 24          |
| Label S   | Noto Sans JP | Bold   | 16   | 20          |

## Flutter Mapping

| Figma Style | Flutter `TextTheme` slot   |
|-------------|----------------------------|
| H1          | `displayLarge`, `headlineLarge` |
| H2          | `headlineMedium`           |
| Body L      | `bodyLarge`                |
| Body M      | `bodyMedium`               |
| Body S      | `bodySmall`                |
| Label L     | `labelLarge`               |
| Label S     | `labelSmall`               |
| Title (M)   | `titleMedium` (Poppins 18) |
| Title (S)   | `titleSmall` (Poppins 16)  |

## Component Patterns

### Card radius
- Standard cards: **16 dp**
- Day column panels (ChildScreen): **24 dp**

### Button radius
- Pill buttons (filled, outlined, segmented): **40 dp**

### Shadows
- Card default: `BoxShadow(color: 0x26000000, blurRadius: 8, offset: Offset(2, 4))`
- Day header / emoji pill: `BoxShadow(color: 0x26000000, blurRadius: 5)`
- Emoji pill: `BoxShadow(color: 0x26484848, blurRadius: 4, offset: Offset(1, 2))`

### Mood / Rating Emojis
Rating 1–4 scale: 😢 😐 🙂 😄

### Confetti (Item Detail)
Colors: `primaryBlueLighter20`, `primaryBlueLighter10`, `primaryBlueBase`, `blossomPinkLighter10`, `blossomPinkBase`

## Implementation Files
- **Palette constants**: `lib/core/theme/app_colors.dart`
- **Theme (ColorScheme + TextTheme)**: `lib/core/theme/app_theme.dart`
- **Fonts**: `google_fonts` package — Poppins, Karla, Noto Sans JP
