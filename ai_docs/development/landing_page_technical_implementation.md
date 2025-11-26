# Landing Page Technical Implementation

**Document Version:** 1.0
**Last Updated:** 2025-11-26
**Status:** Production (Live)
**File:** `/Users/anton/Documents/Development/defitracker/app/views/home/index.html.erb`
**Deployment:** Kamal (Docker)
**Server:** Puma (Rails 8.1)

## Overview

This document provides technical details for developers working with the DeFi Tracker landing page. It covers implementation patterns, code organization, performance optimizations, and maintenance procedures.

## Architecture

### Single-File Architecture

**Decision:** Entire landing page in one `.html.erb` file with inline CSS and minimal JavaScript.

**File Structure:**
```
/app/views/home/index.html.erb (1,392 lines)
├── HTML Head (lines 1-15)
│   ├── Meta tags
│   ├── Favicon links
│   └── Font imports
├── CSS Styles (lines 16-1012)
│   ├── CSS Variables (16-65)
│   ├── Base Styles (67-112)
│   ├── Section Styles (114-896)
│   ├── Animations (898-921)
│   └── Responsive (923-1011)
├── HTML Body (lines 1014-1366)
│   ├── Hero Section (1019-1065)
│   ├── Trust Bar (1067-1095)
│   ├── Features (1097-1173)
│   ├── Social Proof (1176-1261)
│   ├── Pricing (1263-1323)
│   └── Final CTA (1325-1366)
└── JavaScript (lines 1371-1389)
    └── Intersection Observer
```

### Rails Integration

**Route:**
```ruby
# config/routes.rb
root "home#index"
```

**Controller:**
```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    # No logic needed - static landing page
  end
end
```

**View:**
```ruby
# app/views/home/index.html.erb
# Full HTML document (not layout wrapped)
```

### Why This Architecture?

**Pros:**
- Single deployment unit
- No external dependencies
- Fast first paint (no CSS blocking)
- Easy to A/B test (swap entire file)
- Simple cache strategy

**Cons:**
- Large HTML file (60KB)
- No CSS caching
- Limited reusability
- Manual responsive management

## CSS Architecture

### Design Token System

All design values centralized as CSS custom properties:

```css
:root {
  /* Colors */
  --color-bg-primary: #0A0A0A;
  --color-accent-primary: #10B981;

  /* Typography */
  --font-display: 'Unbounded', sans-serif;
  --font-body: 'Onest', sans-serif;

  /* Spacing */
  --spacing-xl: 64px;
  --spacing-2xl: 100px;

  /* Shadows */
  --shadow-lg: 0 8px 48px rgba(0, 0, 0, 0.6);

  /* Radius */
  --radius-lg: 24px;
}
```

### Usage Pattern

```css
.element {
  background: var(--color-bg-primary);
  padding: var(--spacing-xl);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  font-family: var(--font-body);
}
```

### Benefits

- **Theming:** Change entire color scheme by updating root variables
- **Consistency:** Single source of truth for all values
- **Maintainability:** Update once, applies everywhere
- **Runtime updates:** Can be changed via JavaScript if needed

### Extracting to External CSS (Future)

If needed to externalize CSS:

```ruby
# 1. Extract CSS variables to shared file
# app/assets/stylesheets/design_tokens.css

# 2. Extract component styles
# app/assets/stylesheets/components/hero.css
# app/assets/stylesheets/components/features.css

# 3. Import in application.css
# @import "design_tokens";
# @import "components/*";

# 4. Reference in layout
# <%= stylesheet_link_tag "application" %>
```

## JavaScript Implementation

### Intersection Observer Pattern

**Purpose:** Trigger animations when elements enter viewport.

```javascript
const observerOptions = {
  threshold: 0.1,        // Trigger when 10% visible
  rootMargin: '0px 0px -50px 0px'  // Trigger 50px before bottom
};

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('revealed');
      // Note: We don't unobserve, so animation only happens once
    }
  });
}, observerOptions);

// Observe all elements with .scroll-reveal class
document.querySelectorAll('.scroll-reveal').forEach(el => {
  observer.observe(el);
});
```

### CSS Animation Classes

**Initial State:**
```css
.scroll-reveal {
  opacity: 0;
  transform: translateY(40px);
  transition: all 0.8s cubic-bezier(0.4, 0, 0.2, 1);
}
```

**Revealed State:**
```css
.scroll-reveal.revealed {
  opacity: 1;
  transform: translateY(0);
}
```

### Adding Scroll Reveal to New Elements

```html
<div class="new-section scroll-reveal">
  <!-- Content here -->
</div>
```

The Intersection Observer will automatically detect and animate it.

### Accessibility Considerations

**Respect User Preferences:**
```css
@media (prefers-reduced-motion: reduce) {
  .scroll-reveal {
    transition: none;
    opacity: 1;
    transform: none;
  }
}
```

Users who prefer reduced motion see content immediately without animations.

## Responsive Design Implementation

### Breakpoint Strategy

```css
/* Mobile First (default): 320px - 640px */
.element {
  /* Mobile styles here */
}

/* Large Mobile: 640px+ */
@media (min-width: 640px) {
  /* Adjustments for larger phones */
}

/* Tablet: 968px+ */
@media (max-width: 968px) {
  /* Major layout changes */
}

/* Desktop: 968px+ (default in this file) */
/* Desktop styles are primary, mobile is override */
```

### Mobile Overrides Pattern

**Hero Section Example:**
```css
/* Desktop (default) */
.hero-content {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: var(--spacing-xl);
}

/* Tablet/Mobile */
@media (max-width: 968px) {
  .hero-content {
    grid-template-columns: 1fr;  /* Stack */
    gap: var(--spacing-lg);      /* Reduce gap */
  }

  .hero-visual {
    order: -1;  /* Move visual above text */
  }

  .hero-text {
    text-align: center;  /* Center on mobile */
  }
}
```

### Responsive Typography

**Fluid Scaling with clamp():**
```css
.hero h1 {
  font-size: clamp(2.5rem, 6vw, 4.5rem);
  /* Min: 2.5rem (40px)
     Preferred: 6% of viewport width
     Max: 4.5rem (72px) */
}
```

**Benefits:**
- Smooth scaling across all screen sizes
- No breakpoint jumps
- Readable at all sizes

### Touch Target Optimization

**Minimum Size:**
```css
.cta-primary,
.cta-secondary {
  padding: 18px 36px;  /* Exceeds 44px min height */
}

/* Mobile: Full width for easier tapping */
@media (max-width: 640px) {
  .cta-primary,
  .cta-secondary {
    width: 100%;
    justify-content: center;
  }
}
```

### Responsive Testing Checklist

- [ ] iPhone SE (320px width)
- [ ] iPhone 12/13 (390px)
- [ ] iPhone 14 Pro Max (430px)
- [ ] iPad Mini (768px)
- [ ] iPad Pro (1024px)
- [ ] Desktop (1280px, 1440px, 1920px)

## Performance Optimization

### Critical Rendering Path

**1. HTML (Inline CSS):**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    /* All CSS inline - no external request */
  </style>
</head>
```

**Benefits:**
- No render-blocking CSS request
- Faster First Contentful Paint (FCP)
- No Flash of Unstyled Content (FOUC)

**2. Font Loading:**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Unbounded:wght@400;600;800&family=Onest:wght@300;400;500;600;700&display=swap" rel="stylesheet">
```

**Optimizations:**
- `preconnect`: Establishes early connection
- `display=swap`: Show fallback font immediately
- Only load needed weights (not entire family)

**3. JavaScript:**
```html
<script>
  // Minimal JS at bottom of body
  // Non-blocking (after content loads)
</script>
```

### Image Optimization

**Favicon Strategy:**
```html
<link rel="icon" type="image/png" href="/icon.png" sizes="512x512">
<link rel="icon" type="image/svg+xml" href="/icon.svg">
<link rel="apple-touch-icon" href="/icon.png">
```

**No Hero Images:**
- Landing page uses CSS backgrounds and SVG grain
- No large image downloads
- Faster page load

### Performance Metrics

**Target Web Vitals:**
- LCP (Largest Contentful Paint): < 2.5s
- FID (First Input Delay): < 100ms
- CLS (Cumulative Layout Shift): < 0.1

**Measurement:**
```javascript
// In browser console
web-vitals.getCLS(console.log);
web-vitals.getFID(console.log);
web-vitals.getLCP(console.log);
```

Or use Lighthouse in Chrome DevTools.

### Caching Strategy

**Rails Cache Headers:**
```ruby
# config/environments/production.rb
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

**HTML Caching:**
```ruby
# In controller (if needed):
expires_in 1.hour, public: true
```

For static landing page, consider CDN caching (Cloudflare, etc.).

## Animation System

### Keyframe Animations

**fadeInUp (used throughout):**
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

**float (hero gradient):**
```css
@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(-50px, 50px); }
}
```

**rotate (community gradient):**
```css
@keyframes rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```

### Transition Timing

**Easing Function:**
```css
transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
```

This is Material Design's "standard easing" - feels natural and professional.

**Duration Guidelines:**
- Micro-interactions: 0.15-0.3s
- Card hovers: 0.3-0.4s
- Page load animations: 0.6-0.8s
- Background animations: 15-20s (slow, atmospheric)

### Animation Performance

**GPU Acceleration:**
```css
.element {
  transform: translateY(-8px);  /* Uses GPU */
  will-change: transform;       /* Hints to browser */
}
```

**Avoid:**
```css
/* Bad - triggers layout recalculation */
.element:hover {
  width: 110%;
  margin-top: -10px;
}

/* Good - uses transform */
.element:hover {
  transform: translateY(-10px) scale(1.1);
}
```

## Component Patterns

### Card Component

**Standard Pattern:**
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

**Usage:**
```html
<div class="card scroll-reveal">
  <div class="card-icon">🔗</div>
  <h3>Card Title</h3>
  <p>Card description text...</p>
</div>
```

### Button Components

**Primary CTA:**
```html
<a href="#" class="cta-primary">
  Button Text
</a>
```

**Secondary CTA:**
```html
<a href="#" class="cta-secondary">
  Button Text
</a>
```

**Styling:**
```css
.cta-primary {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  background: var(--color-accent-primary);
  color: var(--color-bg-primary);
  padding: 18px 36px;
  border-radius: var(--radius-full);
  text-decoration: none;
  font-weight: 700;
  font-size: 1.1rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: var(--shadow-accent);
}

.cta-primary:hover {
  background: var(--color-accent-secondary);
  transform: translateY(-2px);
  box-shadow: 0 12px 48px rgba(16, 185, 129, 0.4);
}
```

### Section Header Pattern

**Structure:**
```html
<div class="section-header scroll-reveal">
  <span class="section-label">Label</span>
  <h2 class="section-title">Title</h2>
  <p class="section-description">Description</p>
</div>
```

**Styling:**
```css
.section-header {
  text-align: center;
  max-width: 800px;
  margin: 0 auto var(--spacing-2xl);
}

.section-label {
  font-size: 0.875rem;
  color: var(--color-accent-primary);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  font-weight: 700;
  margin-bottom: var(--spacing-sm);
  display: block;
}

.section-title {
  font-family: var(--font-display);
  font-size: clamp(2rem, 4vw, 3.5rem);
  font-weight: 800;
  line-height: 1.2;
  margin-bottom: var(--spacing-md);
  letter-spacing: -0.02em;
}

.section-description {
  font-size: 1.2rem;
  color: var(--color-text-secondary);
  line-height: 1.7;
}
```

## Deployment Process

### Local Development

**Start Server:**
```bash
cd /Users/anton/Documents/Development/defitracker
bin/dev
```

**Access:**
```
http://localhost:3000
```

**Make Changes:**
1. Edit `/app/views/home/index.html.erb`
2. Refresh browser (no build step)
3. Changes appear immediately

### Production Deployment

**Current Setup:** Kamal (Docker-based deployment)

**Deploy Command:**
```bash
bin/kamal deploy
```

**Deployment Steps:**
1. Kamal builds Docker image
2. Pushes to container registry
3. Pulls on production server
4. Starts new container
5. Routes traffic to new container
6. Stops old container

**Verify Deployment:**
```bash
bin/kamal app details
```

**View Logs:**
```bash
bin/kamal app logs
```

**Live URL:**
```
https://idea.defitracker.online
```

### Rollback Procedure

**If deployment fails:**
```bash
bin/kamal rollback
```

**Manual rollback:**
```bash
git revert HEAD
git push origin main
bin/kamal deploy
```

## Testing Strategy

### Visual Regression Testing

**Manual Checklist:**
- [ ] Hero section displays correctly
- [ ] All fonts load (no fallback fonts shown)
- [ ] Colors match design system
- [ ] Animations trigger on scroll
- [ ] Hover states work on all interactive elements
- [ ] Mobile layout stacks correctly
- [ ] Portfolio card shows numbers
- [ ] Pricing cards align properly

### Cross-Browser Testing

**Required Browsers:**
- Chrome (latest)
- Safari (latest)
- Firefox (latest)
- Edge (latest)
- Mobile Safari (iOS 15+)
- Chrome Mobile (Android)

**Known Issues:**
- Safari sometimes doesn't load fonts immediately (display: swap helps)
- Older browsers don't support CSS variables (acceptable, graceful degradation)

### Accessibility Testing

**Tools:**
- Lighthouse (Chrome DevTools)
- axe DevTools (browser extension)
- Keyboard navigation test

**Checklist:**
- [ ] All interactive elements keyboard accessible
- [ ] Focus states visible
- [ ] Color contrast meets WCAG AA
- [ ] Semantic HTML structure
- [ ] Alt text for images (if added)
- [ ] Headings in logical order (H1 → H2 → H3)

### Performance Testing

**Tools:**
- Lighthouse
- WebPageTest
- Chrome DevTools Performance tab

**Target Scores:**
- Performance: 90+
- Accessibility: 95+
- Best Practices: 90+
- SEO: 90+

## Maintenance Guide

### Adding New Section

**1. Add HTML:**
```html
<section class="new-section">
  <div class="container">
    <div class="section-header scroll-reveal">
      <span class="section-label">Label</span>
      <h2 class="section-title">Title</h2>
      <p class="section-description">Description</p>
    </div>

    <!-- Section content -->
  </div>
</section>
```

**2. Add CSS:**
```css
.new-section {
  padding: var(--spacing-3xl) 0;
  background: var(--color-bg-secondary);
}

/* Add responsive styles */
@media (max-width: 968px) {
  .new-section {
    padding: var(--spacing-2xl) 0;
  }
}
```

**3. Test:**
- Visual appearance
- Scroll animation
- Responsive behavior
- Cross-browser

### Updating Content

**Text Changes:**
```ruby
# Find text in /app/views/home/index.html.erb
# Edit directly (Russian text)
# No rebuild needed
```

**Number Changes:**
```ruby
# Update portfolio numbers
# Update stats (10,000+ users, etc.)
# Update pricing (if changed)
```

**Image Changes:**
```ruby
# Replace files in /public/
# Update href in HTML
```

### Updating Design Tokens

**Colors:**
```css
:root {
  --color-accent-primary: #10B981;  /* Change here */
}
/* All usages update automatically */
```

**Spacing:**
```css
:root {
  --spacing-xl: 64px;  /* Adjust here */
}
```

**Typography:**
```css
:root {
  --font-display: 'Unbounded', sans-serif;  /* Change font */
}
```

### A/B Testing Setup

**Option 1: Duplicate File**
```ruby
# app/views/home/index_variant_b.html.erb
# Controller routing based on variant
def index
  if params[:variant] == 'b'
    render 'index_variant_b'
  else
    render 'index'
  end
end
```

**Option 2: Conditional Rendering**
```ruby
<% if ab_test(:hero_cta) == 'variant_b' %>
  <%= render 'hero_variant_b' %>
<% else %>
  <%= render 'hero_variant_a' %>
<% end %>
```

## Troubleshooting

### Fonts Not Loading

**Symptom:** System fonts appear instead of Unbounded/Onest

**Causes:**
- Google Fonts blocked
- CORS issue
- Slow network

**Fix:**
```html
<!-- Ensure preconnect is in place -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Add display=swap -->
<link href="...&display=swap" rel="stylesheet">
```

### Animations Not Triggering

**Symptom:** Elements don't animate on scroll

**Causes:**
- JavaScript not executing
- `.scroll-reveal` class missing
- Browser doesn't support Intersection Observer

**Fix:**
```javascript
// Check if Intersection Observer exists
if ('IntersectionObserver' in window) {
  // Use Intersection Observer
} else {
  // Fallback: show all elements immediately
  document.querySelectorAll('.scroll-reveal').forEach(el => {
    el.classList.add('revealed');
  });
}
```

### Layout Breaking on Mobile

**Symptom:** Content overflows, horizontal scroll appears

**Causes:**
- Fixed width elements
- Viewport units without max-width
- Missing responsive styles

**Fix:**
```css
/* Add to troublesome element */
.element {
  max-width: 100%;
  overflow: hidden;
}

/* Check for fixed widths */
.element {
  width: 1200px;  /* BAD - breaks mobile */
  max-width: 100%;  /* GOOD - responsive */
}
```

### Performance Issues

**Symptom:** Slow page load, janky animations

**Causes:**
- Large images
- Too many animations
- Inefficient CSS selectors

**Diagnosis:**
```bash
# Use Lighthouse
# Check Performance tab in Chrome DevTools
# Look for:
# - Large payload sizes
# - Long tasks
# - Layout shifts
```

**Fixes:**
- Optimize images (use WebP, compress)
- Reduce animation complexity
- Add `will-change` to animated elements
- Use `contain: layout` on isolated sections

## Code Quality

### CSS Best Practices

**DO:**
```css
/* Use design tokens */
color: var(--color-text-primary);

/* Use logical units */
padding: var(--spacing-lg);

/* Use transforms for animations */
transform: translateY(-8px);

/* Use semantic class names */
.hero-content { }
```

**DON'T:**
```css
/* Hardcode colors */
color: #F5F5F5;

/* Use magic numbers */
padding: 37px;

/* Animate layout properties */
margin-top: -10px;

/* Use generic class names */
.box1 { }
```

### HTML Best Practices

**Semantic Structure:**
```html
<section class="features">
  <div class="container">
    <header class="section-header">
      <h2>Title</h2>
    </header>

    <div class="features-grid">
      <article class="feature-card">
        <!-- Feature content -->
      </article>
    </div>
  </div>
</section>
```

**Accessibility:**
```html
<!-- Always use semantic HTML -->
<button>Click me</button>  <!-- Good -->
<div onclick="...">Click me</div>  <!-- Bad -->

<!-- Provide alt text -->
<img src="..." alt="Description">

<!-- Use proper heading hierarchy -->
<h1>Main title</h1>
  <h2>Section</h2>
    <h3>Subsection</h3>
```

## Future Improvements

### Potential Enhancements

1. **Component Library:**
   - Extract reusable components
   - Create Stimulus controllers for interactions
   - Build design system documentation

2. **Internationalization:**
   - Add English version
   - Implement i18n system
   - Language switcher

3. **CMS Integration:**
   - Make content editable via CMS
   - A/B testing framework
   - Analytics integration

4. **Performance:**
   - Lazy load below-fold content
   - Implement critical CSS
   - Add service worker for offline

5. **Advanced Features:**
   - Interactive demo (not just static)
   - Video backgrounds
   - Live user count
   - Dynamic testimonials

### Migration Path to Component Library

**When to migrate:**
- When reusing styles across multiple pages
- When design system grows beyond landing page
- When team size increases

**Steps:**
1. Extract CSS variables to shared file
2. Convert sections to partials
3. Create Stimulus controllers for JS
4. Build Storybook for components
5. Document component API

## Resources

### Documentation

- **Design System:** `/ai_docs/ui/landing_page_design_system.md`
- **Structure:** `/ai_docs/ui/landing_page_structure.md`
- **Design Decisions:** `/ai_docs/ui/landing_page_design_decisions.md`
- **GTM Strategy:** `/ai_docs/business/gtm_manifest.md`

### Tools

- **Lighthouse:** Chrome DevTools → Lighthouse tab
- **Responsive Tester:** Chrome DevTools → Device Toolbar
- **Color Contrast Checker:** https://webaim.org/resources/contrastchecker/
- **Font Pairing:** https://fonts.google.com

### External Resources

- **CSS Custom Properties:** https://developer.mozilla.org/en-US/docs/Web/CSS/--*
- **Intersection Observer:** https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API
- **Web Vitals:** https://web.dev/vitals/
- **Kamal Docs:** https://kamal-deploy.org/

## Changelog

### Version 1.0 (2025-11-26)

**Complete redesign from previous version:**
- New Premium Fintech aesthetic
- Emerald/teal color palette
- Unbounded + Onest typography
- 6-section structure (down from 10)
- Asymmetric layouts
- Scroll-triggered animations
- Mobile-first responsive design
- Inline CSS architecture
- Intersection Observer implementation

**Deployed:** Commit 5275644
**Live:** https://idea.defitracker.online

---

## Contact

For technical questions about landing page implementation, refer to this document or contact the development team.
