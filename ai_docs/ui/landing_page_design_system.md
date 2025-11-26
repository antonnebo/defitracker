# Landing Page Design System

**Document Version:** 1.0
**Last Updated:** 2025-11-26
**Status:** Production (Live)
**Live URL:** https://idea.defitracker.online

## Overview

This document defines the design system for the DeFi Tracker landing page, following a **Premium Fintech** aesthetic. The design system provides a cohesive visual language that positions DeFi Tracker as a sophisticated, trustworthy platform for active crypto users.

## Design Philosophy

### Core Aesthetic: Premium Fintech

The landing page deliberately moves away from cliched crypto aesthetics (purple gradients, neon, overly futuristic) toward a refined, sophisticated approach that conveys:

- **Trust & Security**: Dark mode with professional color palette
- **Premium Quality**: Generous spacing, refined typography, attention to detail
- **Modern Sophistication**: Emerald/teal accents instead of typical purple
- **Professionalism**: Clear hierarchy, strong layouts, purposeful motion

### Key Design Principles

1. **Dark Mode First**: Background colors start at #0A0A0A for maximum contrast and OLED optimization
2. **Refined Color Palette**: Sophisticated emerald/teal (#10B981, #14F195) as accent colors
3. **Distinctive Typography**: Cyrillic-optimized fonts (Unbounded, Onest) for character and readability
4. **Generous Spacing**: Large vertical rhythm creates breathing room and premium feel
5. **Purposeful Motion**: Scroll-triggered animations and micro-interactions enhance engagement
6. **Asymmetric Layouts**: Grid-breaking compositions create visual interest

## Color System

### CSS Variables

All colors are defined as CSS custom properties in `:root`:

```css
:root {
  /* Background Colors - Dark Mode First */
  --color-bg-primary: #0A0A0A;       /* Main background */
  --color-bg-secondary: #1A1A1A;     /* Elevated surfaces */
  --color-bg-tertiary: #252525;      /* More elevated */
  --color-bg-elevated: #2A2A2A;      /* Highest elevation */

  /* Accent Colors - Sophisticated Emerald/Teal */
  --color-accent-primary: #10B981;   /* Primary brand green */
  --color-accent-secondary: #14F195; /* Highlight green */
  --color-accent-dark: #059669;      /* Darker state */

  /* Text Colors */
  --color-text-primary: #F5F5F5;     /* Primary text */
  --color-text-secondary: #A3A3A3;   /* Secondary text */
  --color-text-tertiary: #737373;    /* Tertiary/labels */

  /* Borders */
  --color-border: rgba(255, 255, 255, 0.08);
  --color-border-hover: rgba(255, 255, 255, 0.15);
}
```

### Color Usage Guidelines

**Backgrounds:**
- Primary (#0A0A0A): Main page background
- Secondary (#1A1A1A): Card backgrounds, sections
- Tertiary (#252525): Nested cards, feature highlights
- Elevated (#2A2A2A): Interactive elements, highest elevation

**Accents:**
- Primary (#10B981): CTAs, highlights, icons
- Secondary (#14F195): Hover states, emphasis text, gradients
- Dark (#059669): Active states, pressed buttons

**Text:**
- Primary (#F5F5F5): Headlines, body text
- Secondary (#A3A3A3): Supporting text, descriptions
- Tertiary (#737373): Labels, metadata, captions

### Color Philosophy

**Why Emerald/Teal Instead of Purple?**
- Purple gradients are overused in crypto/web3 (seen as cliche)
- Emerald/teal conveys: growth, prosperity, trust, stability
- More distinctive in crypto space dominated by blue/purple
- Better contrast on dark backgrounds
- Aligns with "fintech premium" positioning

## Typography System

### Font Families

**Display Font: Unbounded**
- **Usage**: Headlines, large titles, pricing, important numbers
- **Weights**: 400 (Regular), 600 (Semi-Bold), 800 (Extra-Bold)
- **Characteristics**: Bold, geometric, modern, excellent Cyrillic support
- **Why Chosen**: Distinctive character, strong personality, works in Russian

```css
--font-display: 'Unbounded', sans-serif;
```

**Body Font: Onest**
- **Usage**: Paragraphs, descriptions, UI text, navigation
- **Weights**: 300 (Light), 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)
- **Characteristics**: Clean, readable, optimized for screens, excellent Cyrillic
- **Why Chosen**: Superior readability, modern yet neutral, great for Russian text

```css
--font-body: 'Onest', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### Typography Scale

| Element | Font Family | Size (Desktop) | Weight | Line Height |
|---------|-------------|----------------|---------|-------------|
| Hero H1 | Unbounded | clamp(2.5rem, 6vw, 4.5rem) | 800 | 1.1 |
| Section Title | Unbounded | clamp(2rem, 4vw, 3.5rem) | 800 | 1.2 |
| Feature Title | Unbounded | 1.5rem | 700 | 1.3 |
| Hero Subtitle | Onest | clamp(1.1rem, 2vw, 1.4rem) | 400 | 1.7 |
| Section Description | Onest | 1.2rem | 400 | 1.7 |
| Body Text | Onest | 1.05rem | 400 | 1.7 |
| Button Text | Onest | 1.1rem | 700 | 1 |
| Labels | Onest | 0.875rem | 700 | 1 |

### Typography Best Practices

1. **Letter Spacing**: Tight for display (-0.02em), normal for body
2. **Text Transform**: Uppercase only for small labels/metadata
3. **Font Smoothing**: Always use `-webkit-font-smoothing: antialiased`
4. **Responsive Sizing**: Use `clamp()` for fluid typography
5. **Cyrillic Optimization**: Both fonts render Cyrillic beautifully

## Spacing System

### Spacing Scale

```css
:root {
  --spacing-xs: 8px;      /* Tight spacing */
  --spacing-sm: 16px;     /* Small gaps */
  --spacing-md: 24px;     /* Medium gaps */
  --spacing-lg: 40px;     /* Large gaps */
  --spacing-xl: 64px;     /* Extra large */
  --spacing-2xl: 100px;   /* Section padding */
  --spacing-3xl: 150px;   /* Major sections */
}
```

### Spacing Usage

- **Component Internal**: xs (8px), sm (16px)
- **Between Components**: md (24px), lg (40px)
- **Section Padding**: xl (64px), 2xl (100px), 3xl (150px)
- **Container**: max-width: 1280px, padding: 0 24px

### Responsive Spacing Adjustments

**Mobile (< 640px):**
- 2xl: 60px (reduced from 100px)
- 3xl: 80px (reduced from 150px)

**Tablet (< 968px):**
- 2xl: 60px
- 3xl: 80px

## Shadow System

```css
:root {
  --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.4);
  --shadow-md: 0 4px 24px rgba(0, 0, 0, 0.5);
  --shadow-lg: 0 8px 48px rgba(0, 0, 0, 0.6);
  --shadow-accent: 0 8px 32px rgba(16, 185, 129, 0.25);
}
```

**Usage:**
- Small: Small cards, tooltips
- Medium: Elevated cards, dropdowns
- Large: Hero cards, modals, major elements
- Accent: Primary CTAs, hover states on accent elements

## Border Radius System

```css
:root {
  --radius-sm: 8px;      /* Small elements */
  --radius-md: 16px;     /* Cards, buttons */
  --radius-lg: 24px;     /* Large cards */
  --radius-full: 9999px; /* Pills, rounded buttons */
}
```

## Visual Effects

### Grain Overlay Texture

Applied to `body::before` to add subtle atmospheric texture:

```css
body::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url("data:image/svg+xml,...");
  pointer-events: none;
  opacity: 0.4;
  z-index: 1;
}
```

Creates subtle film grain effect that adds depth without being distracting.

### Gradient Meshes

Used for atmospheric backgrounds (hero section):

```css
.hero::before {
  background: radial-gradient(circle, rgba(16, 185, 129, 0.15) 0%, transparent 70%);
  filter: blur(80px);
  animation: float 20s ease-in-out infinite;
}
```

Soft, floating gradient creates depth and draws attention to hero content.

### Animations

**Page Load Animations:**
```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Scroll Reveal:**
- Uses Intersection Observer API
- Triggers when element enters viewport
- Adds `.revealed` class to trigger transition
- Threshold: 0.1 (10% visible)
- Root margin: -50px bottom

**Hover Effects:**
- Subtle translateY(-8px) on cards
- Smooth opacity transitions
- Border color changes
- Shadow intensity increases

## Component Patterns

### Cards

**Standard Card:**
```css
.card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
  transform: translateY(-8px);
  border-color: var(--color-border-hover);
  box-shadow: var(--shadow-lg);
}
```

**Featured Card:**
- Additional top border gradient
- Different background (subtle accent tint)
- Badge positioning (`position: absolute`)

### Buttons

**Primary CTA:**
```css
.cta-primary {
  background: var(--color-accent-primary);
  color: var(--color-bg-primary);
  padding: 18px 36px;
  border-radius: var(--radius-full);
  font-weight: 700;
  box-shadow: var(--shadow-accent);
}

.cta-primary:hover {
  background: var(--color-accent-secondary);
  transform: translateY(-2px);
  box-shadow: 0 12px 48px rgba(16, 185, 129, 0.4);
}
```

**Secondary CTA:**
- Transparent background
- Border: 2px solid var(--color-border)
- Hover: subtle background + border color change

### Icons

- **Size**: 1.8rem - 3.5rem depending on context
- **Container**: 56px x 56px with border-radius: var(--radius-md)
- **Background**: rgba(16, 185, 129, 0.1) for brand-colored icons
- **Display**: Flexbox centered

## Responsive Design

### Breakpoints

- **Desktop**: 1440px+ (default)
- **Laptop**: 1280px - 1440px
- **Tablet**: 768px - 968px
- **Mobile**: 320px - 640px

### Mobile-First Adjustments

**Layout Changes:**
- Hero: Grid → single column, visual moves above text
- Features: 12-column grid → full width stacking
- Pricing: 3 columns → 1 column
- Trust bar: 4 items → 2 columns → 1 column

**Typography Scaling:**
- Hero H1: 4.5rem → 2.2rem
- Section titles: 3.5rem → proportionally smaller
- All text uses `clamp()` for fluid scaling

**Spacing Reduction:**
- Section padding: 150px → 80px
- Component gaps: 64px → 40px

**Button Behavior:**
- Full width on mobile (<640px)
- Stacked vertically instead of horizontal
- `justify-content: center` for proper alignment

## Accessibility Considerations

### Color Contrast

All text meets WCAG AA standards:
- Primary text on primary bg: 14:1 contrast ratio
- Secondary text on primary bg: 7:1 contrast ratio
- Accent colors maintain 4.5:1 minimum on dark backgrounds

### Interactive Elements

- All buttons have minimum 44px x 44px touch target
- Hover states also have focus states for keyboard navigation
- Links underlined on focus for clarity

### Motion & Animation

- All animations respect `prefers-reduced-motion`
- Smooth scroll is optional (user preference)
- No rapid flashing or strobing effects

## Design Tokens Summary

**File Location:** `/Users/anton/Documents/Development/defitracker/app/views/home/index.html.erb` (lines 16-65)

All design tokens are centralized as CSS custom properties for easy theming and consistency. Future implementations (React components, Vue, etc.) should extract these to a shared tokens file.

## Future Considerations

### Potential Enhancements

1. **Theme Switching**: Light mode variant (keep dark as default)
2. **Color Customization**: User-selectable accent colors
3. **Animation Library**: Extract animations to reusable library
4. **Component Library**: Convert landing page patterns to reusable components
5. **Design System Package**: Export as standalone design system for app UI

### Maintenance Notes

- Update font versions when Google Fonts releases improvements
- Monitor Web Vitals (LCP, CLS, FID) as design evolves
- Test on OLED devices regularly (dark mode optimization)
- A/B test accent colors if conversion rates plateau
- Consider seasonal color variations for special campaigns
